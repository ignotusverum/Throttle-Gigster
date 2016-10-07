//
//  BankSearchViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-26.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class BankSearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarHolderView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var noResultsView: UIView!
	@IBOutlet var loaderView: UIView!
	@IBOutlet var searchBar: UISearchBar!
	
	var addManuallyButtonTapped = false;
	let segueToAddManuallyIdentifier = "segueToAddManually";
    
    private let throttleCommsManager = ThrottleCommunicationsManager.defaultManager
    private var popularBanks: [Bank]? = nil
	private var searchDelayer : NSTimer?;
	let bankSearchCollectionViewCellIdentifier = "BankSearchCollectionViewCellIdentifier";
	let bankLoginSegueId = "bankLoginSegueIdentifier";
	
	//MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.searchBar.delegate = self;
		
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Select your bank", comment: "")
		self.collectionView.collectionViewLayout = CustomHomeCollectionViewFlowLayout();
		self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: "handlePopGesture:");
		
		noResultsView.hidden = true;
        populatePopularBanks()
		self.searchBar.keyboardAppearance = .Dark;
    }

	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.blueBarColor();
		navigationController!.navigationBar.tintColor = Theme.blueBarTextColor();
		navigationController!.setNavigationBarHidden(false, animated: true)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true);
		if (self.addManuallyButtonTapped) {
			self.addManuallyButtonTapped = false;
			self.performSegueWithIdentifier(self.segueToAddManuallyIdentifier, sender: nil);
		}
		
		self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action: "handlePopGesture:");
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(true);
		self.navigationController?.interactivePopGestureRecognizer?.removeTarget(self, action: "handlePopGesture:");
	}
	

	
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.view.endEditing(true);
		//get rid of the back button text, per mock ups
		let backItem = UIBarButtonItem();
		backItem.title = "";
		navigationItem.backBarButtonItem = backItem;
		
        if segue.identifier == bankLoginSegueId {
            let currentIndex = collectionView.indexPathsForSelectedItems()!.last!.row
            let viewController = segue.destinationViewController as! BankLoginViewController
			viewController.delegate = self;
			viewController.selectedBank = popularBanks![currentIndex];
        }
    }
    
    // MARK: - Gestures
	func handlePopGesture(gesture: UIGestureRecognizer) {
		if (gesture.state == UIGestureRecognizerState.Began)
		{
			self.view.endEditing(true);
			print("began");
		}
	}
	
    func tap(recognizer: UITapGestureRecognizer) {
		self.view.endEditing(true);
    }
	
    private func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
	
	//MARK: - Helpers
    private func populatePopularBanks() {
		self.loaderView.hidden = false;
        self.throttleCommsManager.fetchPopularBanks({ (banks, error) -> Void in
			self.loaderView.hidden = true;
            if (nil == error) {
                if banks!.count == 0 {
                    self.noResultsView.hidden = false
                } else {
                    self.noResultsView.hidden = true
                    self.popularBanks = banks
                    self.collectionView.reloadData()
                }
                
            } else {
				print(error);
            }
		});
    }
	
	deinit {
		print("deinit called on bank search VC");
	}
}

//MARK: - UICollectionViewDelegate
extension BankSearchViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:
		NSIndexPath) {
    }
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.view.endEditing(true);
	}
	
}

//MARK: - UICollectionViewDataSource
extension BankSearchViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularBanks?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bankSearchCollectionViewCellIdentifier, forIndexPath: indexPath) as! BankSearchCollectionViewCell
		
        self.loadCellAtIndex(cell, index: indexPath.item)
        return cell
    }
    
    private func loadCellAtIndex(cell: BankSearchCollectionViewCell, index: Int) {
        cell.bankLogoImageView.image = nil
		cell.backgroundColor = UIColor.whiteColor();
		cell.userInteractionEnabled = true;
		cell.noBankLogoLabel.hidden = true;
		cell.noBankLogoLabel.text = "No Bank Logo";
        let bank = self.popularBanks![index]
        
        // Check our image cache for the existing key. This is a dictionary of UIImages
        if bank.logoURLString != nil {
			cell.bankLogoImageView.sd_setImageWithURL(NSURL(string: bank.logoURLString!), completed: { (image, error, cacheType, url) -> Void in
				if (error != nil) {
					cell.noBankLogoLabel.hidden = false;
					cell.noBankLogoLabel.text = bank.name;
				}
			});
        }
    }
}

//MARK: - UISearchBarDelegate
extension BankSearchViewController: UISearchBarDelegate {
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		self.searchDelayer?.invalidate();
		self.searchDelayer = nil;
		
		self.searchDelayer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "executeDelayedSearch:", userInfo: searchText, repeats: false);
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		self.view.endEditing(true);
	}
	
	func executeDelayedSearch(timer: NSTimer) {
		var searchTerm = timer.userInfo as! String;
		self.loaderView.hidden = false;
		
		if (searchTerm.characters.count > 0) {
			searchTerm = searchTerm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
			if (searchTerm.characters.count <= 0) {
				self.loaderView.hidden = true;
				return;
			}
			
			throttleCommsManager.fetchBanksWithName(searchTerm, completionHandler: { (banks, error) -> Void in
				self.loaderView.hidden = true;
				if nil == error {
					
					if banks!.count == 0 {
						
						self.noResultsView.hidden = false
						self.popularBanks = []
						self.collectionView.reloadData()
						
					} else {
						
						self.noResultsView.hidden = true
						
						self.popularBanks = banks
						self.collectionView.reloadData()
					}
					
				} else {
					self.noResultsView.hidden = false
					self.popularBanks = []
					self.collectionView.reloadData()
					print(error)
				}
			});
		}
		else {
			populatePopularBanks();
		}

	}
}

extension BankSearchViewController : BankLoginViewControllerDelegate {
	func bankLoginAddManuallyTapped() {
		addManuallyButtonTapped = true;
		self.navigationController?.popViewControllerAnimated(true);
	}
}
