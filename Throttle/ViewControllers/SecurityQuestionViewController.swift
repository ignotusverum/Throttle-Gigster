//
//  SecurityQuestionViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-12-14.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit;
import MBProgressHUD;
import RealmSwift;
import Crashlytics;

class SecurityQuestionViewController: BaseViewController, UITextFieldDelegate {

	@IBOutlet var securityImageHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var tableView: UITableView!
	let chooseAccountSegueIdentifier = "chooseAccountSegueIdentifier";
	let segueToSomethingWentWrongIdentifier = "segueToSomethingWentWrong";
	let segueToWrongAnswerIdentifier = "segueToWrongAnswer";
	let segueToSuccessIdentifier = "segueToSuccess";
	
	let screenType = UIDeviceInfo.screenType();
	var bankLoginResult : KeepCheckingBankLoginResult!;
	var bankLoginService : LogIntoBankAndKeepCheckingBankLoginService!;
	var dbBankAccount : UserAccountEntity?;
	
	var securityQuestionFields : [UITextField] = [];
	
	//MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Account Security Question";
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.separatorStyle = .None;
		self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0);
		
		self.securityQuestionFields = [];
		
		if (self.screenType == UIDeviceInfo.ScreenType.iPhone4)
		{
			self.securityImageHeightConstraint.constant = 80;
		}
		
		if (dbBankAccount == nil) {
			fatalError("Bank account db entity null");
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.greenBarColor();
		navigationController!.navigationBar.tintColor = Theme.greenBarTextColor();
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.view.endEditing(true);
		//get rid of the back button text, per mock ups
		let backItem = UIBarButtonItem();
		backItem.title = "";
		navigationItem.backBarButtonItem = backItem;
	}



	
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
		self.executeSecurityQuestionSubmission();
        return true
    }
    
    // MARK: - Button Events
    @IBAction func done(sender: AnyObject) {
        self.view.endEditing(true);
		self.executeSecurityQuestionSubmission();
    }

	
	// MARK: - Helpers
	func executeSecurityQuestionSubmission() {
		//validate
		let text = "";
		
		MBProgressHUD.showHUDAddedTo(self.view, animated: true);
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				MBProgressHUD.hideHUDForView(self.view, animated: true);
				
				if (text.lowercaseString == "success") {
					self.executeSuccess();
				}
				else if (text.lowercaseString == "api error") {
					self.executeApiError();
				}
				else {
					self.executeWrongAnswer();
				}
			});
		}
	}
	
	//MARK: - Actions to security question submission
	func executeSuccess() {
		//Save the db bank account
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true);
		hud.labelText = "Retrieving data";
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let refreshService = RefreshAllAccountDataService(auth: ConfigFactory.getAuth());
			refreshService.execute({ (result) in
				let saveDataService = SaveRefreshDataService();
				saveDataService.saveRefreshResult(result);
				
				dispatch_async(dispatch_get_main_queue(), { 
					hud.hide(true);
					self.performSegueWithIdentifier(self.segueToSuccessIdentifier, sender: nil);
				});
			});
		}
	}
	
	func executeApiError() {
		self.performSegueWithIdentifier(self.segueToSomethingWentWrongIdentifier, sender: nil);
	}
	
	func executeWrongAnswer() {
		self.performSegueWithIdentifier(self.segueToWrongAnswerIdentifier, sender: nil);
	}
	
	func submitButtonTapped() {
		var answers : [String] = [];
		var noErrors = true;
		for textField in self.securityQuestionFields {
			if let text = textField.text where text.characters.count > 0
			{
				answers.append(text);
			}
			else {
				self.presentViewController(AlertUtil.getSimpleAlert("Validation Error", message: "All security questions are required"), animated: true, completion: nil);
				noErrors = false;
				break;
			}
		}
		
		if (noErrors) {
			self.view.endEditing(true);
			let hud = MBProgressHUD.showHUDAddedTo(self.parentViewController!.view, animated: true);
			hud.labelText = "This may take a few minutes";
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
				self.bankLoginService.sendSecurityQuestionAnswers(self.bankLoginResult.accountId!, answers: answers, completionBlock: { (result) in
					
					dispatch_async(dispatch_get_main_queue(), {
						MBProgressHUD.hideHUDForView(self.parentViewController!.view, animated: true);
						
						if (result.code == .Success) {
							self.executeSuccess();
						}
						else {
							self.executeWrongAnswer();
						}
					});
				});
			});
		}
	}
}

extension SecurityQuestionViewController : UITableViewDataSource, UITableViewDelegate {
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.bankLoginResult.bankSecurityQuestions!.count + 1;
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if (indexPath.row == self.bankLoginResult.bankSecurityQuestions!.count) {
			let cell = tableView.dequeueReusableCellWithIdentifier("CellSubmit");
			let submitButton = cell?.viewWithTag(1) as! UIButton;
			submitButton.addTarget(self, action: #selector(SecurityQuestionViewController.submitButtonTapped), forControlEvents: .TouchUpInside);
			
			return cell!;
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell");
		let textField = cell?.viewWithTag(1) as! UITextField;
		self.securityQuestionFields.append(textField);
		
		let question = self.bankLoginResult!.bankSecurityQuestions![indexPath.row];
		textField.placeholder = question;
		textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]);
		
		return cell!;
	}
}
