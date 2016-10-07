//
//  ViewController.swift
//  Paging_Swift
//
//  Created by Olga Dalton on 26/10/14.
//  Copyright (c) 2014 swiftiostutorials.com. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var splashImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    private var tutorialViewControllers: [UIViewController]?

	var pagerViews : [UIView] = [];
	
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
		
		
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupSplashTimer()
    }
    
    private func populateTutorialViewControllers() {
    
        self.tutorialViewControllers = [self.storyboard!.instantiateViewControllerWithIdentifier("TutorialPageOneViewControllerIdentifier"),
                        self.storyboard!.instantiateViewControllerWithIdentifier("TutorialPageTwoViewControllerIdentifier"),
                        self.storyboard!.instantiateViewControllerWithIdentifier("TutorialPageThreeViewControllerIdentifier")]
    }
    
    private func setupSplashTimer() {
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "createPageViewController", userInfo: nil, repeats: false)
    }
    
    func createPageViewController() {
        
        self.populateTutorialViewControllers()
		
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("TutorialViewControllerIdentifier") as! UIPageViewController
        pageController.dataSource = self
        
        pageController.setViewControllers([self.tutorialViewControllers![0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        
        self.pageViewController!.view.alpha = 0
        self.view.addSubview(self.pageViewController!.view)
        
        UIView.animateWithDuration(0.5, animations: {
            
            self.pageViewController!.view.alpha = 1
            
            }, completion: { (_: Bool) in
                self.splashImageView.hidden = true
                self.logoImageView.hidden = true
                self.titleLabel.hidden = true
                self.subtitleLabel.hidden = true
        })
       
		pageViewController!.didMoveToParentViewController(self);
		
		var widthOfPagerView : CGFloat = 50;
		let rightMargin : CGFloat = 4;
		widthOfPagerView += CGFloat(self.tutorialViewControllers!.count) * rightMargin;
		
		let centerX = (self.view.frame.size.width / CGFloat(2)) - (widthOfPagerView / CGFloat(2));
		let heightOfBottomView : CGFloat = 20;
		let bottomY = self.view.frame.size.height - heightOfBottomView;
		
		let view = UIView(frame: CGRectMake(centerX - 8, bottomY, widthOfPagerView, heightOfBottomView));
		view.backgroundColor = UIColor.clearColor();
		
		var xOffset : CGFloat = 0;
		for index in 0..<self.tutorialViewControllers!.count {
			let widthOfIndividualPageView = widthOfPagerView / CGFloat(3);
			
			if (index > 0) {
				xOffset += widthOfIndividualPageView + rightMargin;
			}
			
			let pagerView = UIView(frame: CGRectMake(xOffset, 0, widthOfIndividualPageView, 2));
			pagerView.backgroundColor = UIColor(white: 1, alpha: 1);
			pagerView.alpha = 0.5;
			self.pagerViews.append(pagerView);
			view.addSubview(pagerView);
		}
		
		self.view.addSubview(view);
		self.updateViewsWithIndex(0);
		
		let skipButton = UIButton(type: .System);
		skipButton.setTitle("Skip", forState: .Normal);
		skipButton.titleLabel!.font = UIFont(name: "KohinoorBangla-Semibold", size: 15)!
		skipButton.tintColor = UIColor.whiteColor();
		skipButton.addTarget(self, action: #selector(TutorialViewController.tappedOnSkipButton), forControlEvents: .TouchUpInside);
		skipButton.frame = CGRect(x: self.view.frame.size.width - 50, y: 25, width: 40, height: 30);
		
		self.view.addSubview(skipButton);
    }

    // MARK: - UIPageViewControllerDataSource
	
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let index = self.tutorialViewControllers!.indexOf(viewController)
		if let theIndex = index {
			self.updateViewsWithIndex(theIndex);
		}
		
        let idx = index! - 1
		
        if idx >= 0 {
            return self.tutorialViewControllers![idx]
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = self.tutorialViewControllers!.indexOf(viewController)
		
		if let theIndex = index {
			self.updateViewsWithIndex(theIndex);
		}
		
        let idx = index! + 1
		
        if idx < self.tutorialViewControllers!.count {
            return self.tutorialViewControllers![idx]
        }
        
        return nil
    }
	
	func updateViewsWithIndex(index: Int) {
		for v in pagerViews {
			v.alpha = 0.5;
		}
		
		let view = pagerViews[index];
		view.alpha = 1;
	}
	
	func tappedOnSkipButton() {
		
		let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SignInViewControllerIdentifier") as! UINavigationController;
		viewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		viewController.navigationBar.shadowImage = UIImage()
		viewController.navigationBar.translucent = true
		
		UIView.transitionFromView(UIApplication.sharedApplication().keyWindow!.rootViewController!.view, toView: viewController.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
			
			UIApplication.sharedApplication().keyWindow?.rootViewController = viewController;
		})
	}
}

