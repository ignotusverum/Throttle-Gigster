//
//  ForgotPasswordCheckEmailViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/17/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class ForgotPasswordCheckEmailViewController: UIViewController {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	@IBAction func closeButtonTapped(sender: AnyObject) {
		self.navigationController?.popToRootViewControllerAnimated(true);
	}
}
