//
//  SuccessViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2016-01-03.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Awesomness!";
        // Do any additional setup after loading the view.
		
		self.navigationItem.setHidesBackButton(true, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(animated: Bool) {
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.blueBarColor();
		navigationController!.navigationBar.tintColor = Theme.blueBarTextColor();
	}

	@IBAction func addAnotherButtonTapped(sender: AnyObject) {
		let controller = self.navigationController?.viewControllers[1];
		self.navigationController?.popToViewController(controller!, animated: true);
	}
	
	@IBAction func proceedButtonTapped(sender: AnyObject) {
		self.navigationController?.popToRootViewControllerAnimated(true);
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
