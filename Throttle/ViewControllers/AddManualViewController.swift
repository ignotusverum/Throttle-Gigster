//
//  AddManualViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-12-19.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit

class AddManualViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var bankNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loansContainerView: UIView!
	
	@IBOutlet var contentViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var bottomConstraintOfNextButton: NSLayoutConstraint!
	@IBOutlet var topSpacingOfTopLabelConstraint: NSLayoutConstraint!
	@IBOutlet var loanTypeBottomView: UIView!
	
	@IBOutlet var accountRequiredErrorLabel: UILabel!
	@IBOutlet var typeRequiredErrorLabel: UILabel!
	@IBOutlet var accountRequired: UILabel!
	@IBOutlet var accountTypeButton: UIButton!
	
	var tapGestureRecognizer: UITapGestureRecognizer? = nil;
	var keyboardOn = false;
	
	//TODO: eventually these will be loaded from a local database
	var loanTypes: [String] = ["Credit Card", "Student Loan", "Checking", "Savings", "Mortgage", "Auto Loan", "Other Loan"];
	
	let almostThereSegueIdentifier = "almostThereSegueIdentifier";
	let loanTypeCellIdentifier = "loanTypeCellIdentifier";
	
	var screenType : UIDeviceInfo.ScreenType?;
	var originalBottomConstraintOfNextButton : CGFloat = 0;
	var originalTopSpacingOfLabelConstraint : CGFloat = 0;
	var originalViewTopConstraint : CGFloat = 0;
	
	var selectedLoanTypeIndex = 0;
	var selectedLoanTypeName : String?;
	
	var manualLoanInfoModel = ManualLoanInfo();
	
	//MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
		self.setupGestureRecognizers();
		self.loansContainerView.hidden = true;
		
		
		self.screenType = UIDeviceInfo.screenType();
		self.originalBottomConstraintOfNextButton = self.bottomConstraintOfNextButton.constant;
		self.originalViewTopConstraint = self.contentViewTopConstraint.constant;
		self.originalTopSpacingOfLabelConstraint = self.topSpacingOfTopLabelConstraint.constant;
		
		if (self.screenType == .iPhone4)
		{
			self.contentViewTopConstraint.constant = 190;
			self.bottomConstraintOfNextButton.constant = 10;
			self.loanTypeBottomView.hidden = true;
		}
		
		self.bankNameTextField.attributedPlaceholder = NSAttributedString(string: self.bankNameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.darkBlueBarColor();
		navigationController!.navigationBar.tintColor = Theme.darkBlueTextColor();
		navigationController!.setNavigationBarHidden(false, animated: true)
	}
    
	
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//get rid of the back button text, per mock ups
		let backItem = UIBarButtonItem();
		backItem.title = "";
		navigationItem.backBarButtonItem = backItem;
		
		if (segue.identifier == almostThereSegueIdentifier)
		{
			let almostThereVC = segue.destinationViewController as! AlmostThereViewController;
			almostThereVC.manualLoanInfoModel = self.manualLoanInfoModel;
		}
    }

    
    // MARK: - Gestures
	private func setupGestureRecognizers() {
		
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
		self.view.addGestureRecognizer(tapGestureRecognizer!)
	}
	
    func tap(recognizer: UITapGestureRecognizer) {
        if !self.keyboardOn {
            return
        }
        
        bankNameTextField.resignFirstResponder()
    }
	
	//MARK: - Keyboard events
	override func keyboardWillShow(notification: NSNotification) {
		if (self.screenType == .iPhone4) {
			var frame = self.view.frame;
			frame.origin.y = -190;
			self.view.frame = frame
		}
		else {
			let userInfo = notification.userInfo! as NSDictionary
			let keyboardFrameValue: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey)as! NSValue
			let rect = keyboardFrameValue.CGRectValue()
			
			
			if (self.screenType == .iPhone5)
			{
				self.topSpacingOfTopLabelConstraint.constant = 9;
				self.contentViewTopConstraint.constant = 60;
			}
			
			self.bottomConstraintOfNextButton.constant = self.bottomConstraintOfNextButton.constant + (rect.height - self.currentKeyboardHeight) - 15;
			self.currentKeyboardHeight = rect.height;
		}
	}
	
	override func keyboardWillHide(notification: NSNotification) {
		if (self.screenType == .iPhone4) {
			super.keyboardWillHide(notification);
		}
		else {
			if (self.screenType == .iPhone5)
			{
				self.topSpacingOfTopLabelConstraint.constant = self.originalTopSpacingOfLabelConstraint;
				self.contentViewTopConstraint.constant = self.originalViewTopConstraint;
			}
			
			self.currentKeyboardHeight = 0;
			if (self.bottomConstraintOfNextButton != nil) {
			self.bottomConstraintOfNextButton.constant = self.originalBottomConstraintOfNextButton;
			}
		}
	}
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
	
	func textFieldDidBeginEditing(textField: UITextField) {
		if (textField == self.bankNameTextField) {
			if (!self.accountRequiredErrorLabel.hidden) {
				self.accountRequiredErrorLabel.hidden = true;
			}
		}
	}


    // MARK: - Button Events
    @IBAction func next(sender: AnyObject) {
		self.view.endEditing(true);
		
		//validation
		guard let acctName = self.bankNameTextField.text
			where acctName.characters.count > 0
			else {
				self.accountRequiredErrorLabel.hidden = false;
				return;
		}
		
		guard let loanTypeName = self.selectedLoanTypeName
			where loanTypeName.characters.count > 0  else {
				self.typeRequiredErrorLabel.hidden = false;
				return;
		}
		

		self.manualLoanInfoModel.accountName = acctName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
		self.manualLoanInfoModel.loanType = loanTypeName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
		
		self.performSegueWithIdentifier(self.almostThereSegueIdentifier, sender: nil);
    }
    
    @IBAction func loanType(sender: AnyObject) {
		tapGestureRecognizer!.cancelsTouchesInView = false;
		self.view.endEditing(true);
		
		self.loansContainerView.alpha = 0;
		self.loansContainerView.hidden = false;
		
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			self.loansContainerView.alpha = 1;
			}) { (complete) -> Void in
				if (complete) {
					
				}
		}
    }
}

//MARK: - UITableViewDataSource
extension AddManualViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10;
	}
	
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loanTypes.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(loanTypeCellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = loanTypes[indexPath.row]
        return cell
    }
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 53;
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRectMake(0,0,1,1));
		view.backgroundColor = UIColor.clearColor();
		return view;
	}
}

//MARK: - UITableViewDelegate
extension AddManualViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.selectedLoanTypeIndex = indexPath.row;
		self.selectedLoanTypeName = self.loanTypes[indexPath.row];
		
		self.accountTypeButton.setTitle(self.selectedLoanTypeName, forState: UIControlState.Normal);
		self.accountRequiredErrorLabel.hidden = true;
		
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			self.loansContainerView.alpha = 0;
			}) { (complete) -> Void in
				if (complete) {
					self.loansContainerView.hidden = true;
					self.tapGestureRecognizer!.cancelsTouchesInView = true
				}
		}
    }
}