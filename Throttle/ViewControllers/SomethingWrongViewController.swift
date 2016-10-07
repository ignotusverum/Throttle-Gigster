//
//  SomethingWrongViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2016-01-03.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class SomethingWrongViewController: UIViewController {
	//MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Something went wrong";
        // Do any additional setup after loading the view.
		self.navigationItem.setHidesBackButton(true, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.redBarColor();
		navigationController!.navigationBar.tintColor = Theme.redBarTextColor();
		navigationController!.setNavigationBarHidden(false, animated: true)
	}
	
	//MARK: - Button events
	@IBAction func tryAgainButtonTapped(sender: AnyObject) {
		self.performSegueWithIdentifier("unwindSegueToBankLogin", sender: nil);
	}
}
