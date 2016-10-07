//
//  TutorialPageThreeViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-19.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit

class TutorialPageThreeViewController: UIViewController {
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBActions
    @IBAction func getStarted(sender: AnyObject?) {
        
		let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SignInViewControllerIdentifier") as! UINavigationController;
		viewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		viewController.navigationBar.shadowImage = UIImage()
		viewController.navigationBar.translucent = true
		
        UIView.transitionFromView(UIApplication.sharedApplication().keyWindow!.rootViewController!.view, toView: viewController.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
            
			UIApplication.sharedApplication().keyWindow?.rootViewController = viewController;
        })
    }
}
