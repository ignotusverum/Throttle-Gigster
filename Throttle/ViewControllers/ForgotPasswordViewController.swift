//
//  ForgotPasswordViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/17/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import MBProgressHUD;

class ForgotPasswordViewController: BaseViewController {
	@IBOutlet var emailText: UITextField!
	@IBOutlet var sendEmailButton: CommonButton!
	var keyboardOn = false;
	@IBOutlet var emailErrorFieldLabel: UILabel!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.emailText.delegate = self;
		self.emailErrorFieldLabel.hidden = true;
		// Do any additional setup after loading the view.
	}
	
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	@IBAction func sendEmailButtonTapped(sender: AnyObject) {
		self.executeForgotPassword();
	}
	
	func executeForgotPassword() {
		self.view.endEditing(true);
		self.keyboardOn = false;
		self.emailErrorFieldLabel.hidden = true;
		self.emailErrorFieldLabel.text = "Email required";

		guard let text = self.emailText.text else {
			self.emailErrorFieldLabel.hidden = false;
			return;
		}
		
		if (text.characters.count <= 0) {
			self.emailErrorFieldLabel.hidden = false;
			return;
		}
		
		if (!isValidEmail(text))
		{
			self.emailErrorFieldLabel.text = "Invalid Email";
			self.emailErrorFieldLabel.hidden = false;
			return;
		}
		
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true);
		hud.dimBackground = true;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			let forgotPasswordService = ForgotPasswordService(email: text);
			forgotPasswordService.execute({ (success) -> Void in
				
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					MBProgressHUD.hideHUDForView(self.view, animated: true);
					
					if (success) {
						self.performSegueWithIdentifier("segueToCheckEmailMessage", sender: nil);
					}
					else {
						self.presentViewController(AlertUtil.getSimpleAlert("Error", message: "Email not found. Please try again"), animated: true, completion: nil);
					}
				});
					
			});
		};
	}

	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		let backItem = UIBarButtonItem();
		backItem.title = "";
		navigationItem.backBarButtonItem = backItem;
	}
}

extension ForgotPasswordViewController : UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.executeForgotPassword();
		return true;
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		if (!self.emailErrorFieldLabel.hidden) {
			self.emailErrorFieldLabel.hidden = true;
		}
	}
}
