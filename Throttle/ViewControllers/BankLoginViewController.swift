//
//  BankLoginViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-12-14.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit
import SDWebImage;
import MBProgressHUD;

protocol BankLoginViewControllerDelegate {
	func bankLoginAddManuallyTapped();
}

class BankLoginViewController: BaseViewController, UITextFieldDelegate {
	var selectedBank : Bank!;
	let bankLoginSecurityQuestionSegueIdentifier = "bankLoginSecurityQuestionSegueIdentifier";
	let segueToSuccessfullyAddedAccount = "segueToSuccessfullyAddedAccount";
	
	let screenType = UIDeviceInfo.screenType();
	let dbBankAccount = UserAccountEntity();
	let auth = ConfigFactory.getAuth();
	
    @IBOutlet var bankLogoImageView: UIImageView!
    @IBOutlet var bankIdTextField: UITextField!
    @IBOutlet var bankSecurityTextField: UITextField!
    @IBOutlet var loginContainerView: UIView!
	@IBOutlet var bankLogoNoImageFoundLabel: UILabel!
	@IBOutlet var usernameRequiredLabel: UILabel!
	@IBOutlet var passwordRequiredLabel: UILabel!

	@IBOutlet var viewWhenUserFocusesTextboxes: UIView!
	@IBOutlet var secondaryBankImageView: UIImageView!
	@IBOutlet var topConstraintOfBankImageContainerView: NSLayoutConstraint!
	
	var delegate : BankLoginViewControllerDelegate?;
	var bankLoginFormResult : GetBankLoginFormResult?;
	var loginService : LogIntoBankAndKeepCheckingBankLoginService?;
	
	
	//MARK: - VC Lifecycle
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BankLoginViewController.textChanged), name:UITextFieldTextDidChangeNotification, object: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "";
		
		if let imageUrl = selectedBank.logoURLString {
			self.bankLogoImageView.sd_setImageWithURL(NSURL(string: imageUrl), completed: { (image, error, cacheType, url) -> Void in
				if (error != nil) {
					self.bankLogoNoImageFoundLabel.hidden = false;
				}
				else {
					self.secondaryBankImageView.image = self.bankLogoImageView.image;
				//bank logo image view is already set, just need to set the secondary view
				}
			});
		}
		
		self.usernameRequiredLabel.hidden = true;
		self.passwordRequiredLabel.hidden = true;
		self.setupGestureRecognizers();
		self.viewWhenUserFocusesTextboxes.hidden = true;
		
		let addManuallyButton : UIBarButtonItem = UIBarButtonItem(title: "Add Manually", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BankLoginViewController.addManuallyButtonTapped))
		self.navigationItem.rightBarButtonItem = addManuallyButton;
		
		if (screenType == UIDeviceInfo.ScreenType.iPhone4) {
			self.topConstraintOfBankImageContainerView.constant = 4;
		}
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
			let service = GetBankLoginFormService(auth: self.auth);
			service.execute(self.selectedBank.id, completionHandler: { (result) in
				if (result.code == .Success) {
					self.bankLoginFormResult = result;
					return;
				}
				
				dispatch_async(dispatch_get_main_queue(), { 
					self.presentViewController(AlertUtil.getSimpleAlert("Error retrieving bank", message: "We apologize. We are unable to process your request for this bank. Please try again later."), animated: true, completion: nil);
					
					self.navigationController?.popViewControllerAnimated(true);
				});
			});
		};
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
		
	}
	
	
	// MARK: - Keyboard event overrides
	override func keyboardWillHide(notification: NSNotification) {
		
			super.keyboardWillHide(notification);
		
		
		if (self.viewWhenUserFocusesTextboxes != nil) {
			self.viewWhenUserFocusesTextboxes.hidden = true;
		}
	}
	
	override func keyboardWillShow(notification: NSNotification) {
		if (self.screenType == .iPhone4)
		{
			var frame = self.view.frame;
			frame.origin.y = -190;
			self.view.frame = frame
		}
		else
		{
			super.keyboardWillShow(notification);
		}
		
		if (self.viewWhenUserFocusesTextboxes != nil) {
			self.viewWhenUserFocusesTextboxes.hidden = false;
		}
	}
	
	
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.view.endEditing(true);
		//get rid of the back button text, per mock ups
		let backItem = UIBarButtonItem();
		backItem.title = "";
		navigationItem.backBarButtonItem = backItem;
		
        if segue.identifier == bankLoginSecurityQuestionSegueIdentifier {
            let viewController = segue.destinationViewController as! SecurityQuestionViewController
			if let result = sender as? KeepCheckingBankLoginResult {
				viewController.bankLoginResult = result;
				viewController.dbBankAccount = self.dbBankAccount;
				viewController.bankLoginService = self.loginService;
			}
        }
    }

	@IBAction func unwindSegueForBankLogin(segue: UIStoryboardSegue) {
		self.bankIdTextField.text = nil;
		self.bankSecurityTextField.text = nil;
	}
	
	
	// MARK: - Nav button events
	func addManuallyButtonTapped() {
		if let d = delegate {
			d.bankLoginAddManuallyTapped();
		}
	}
	
    // MARK: - Gestures
	private func setupGestureRecognizers() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BankLoginViewController.tap(_:)))
		self.view.addGestureRecognizer(tapGestureRecognizer)
	}
	
    func tap(recognizer: UITapGestureRecognizer) {
		self.view.endEditing(true);
    }

    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
		if (textField == self.bankIdTextField) {
			self.bankSecurityTextField.becomeFirstResponder();
		}
		else {
			textField.resignFirstResponder()
			self.executeLogin();
		}
        return true
    }
	
	func textChanged() {
		self.usernameRequiredLabel.hidden = true
		self.passwordRequiredLabel.hidden = true
	}
	
	//MARK: - Button events
	@IBAction func questionButtonTapped(sender: AnyObject) {
		let alertController = AlertUtil.getSimpleAlert("Info", message: "Please enter your bank credentials");
		self.presentViewController(alertController, animated: true, completion: nil);
	}
	
    // MARK: - Login actions and responses
	func executeLogin() {
		self.view.endEditing(true);
		
		guard let username = self.bankIdTextField.text
			where username.characters.count > 0
			else {
				self.usernameRequiredLabel.hidden = false;
				return;
		}
		
		guard let password = self.bankSecurityTextField.text
			where password.characters.count > 0
			else {
				self.passwordRequiredLabel.hidden = false;
				return;
		}
		
		self.loginService = LogIntoBankAndKeepCheckingBankLoginService(un: username, pw: password, bId: self.selectedBank.id, auth: self.auth) { (result) in
		
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				MBProgressHUD.hideHUDForView(self.view, animated: false);
				
				if (result.code == StatusCodes.Success) {
					self.dbBankAccount.userName = username;
					self.dbBankAccount.accountId = self.selectedBank.id;
					self.dbBankAccount.accountName = self.selectedBank.name;
					
					self.successfullyLoggedIntoBank(result);
				}
				else {
					self.errorLoggingIntoBank(result);
				}
				
			});
			
		};
		
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true);
		hud.labelText = "This may take a few minutes";
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			self.loginService!.execute();
		};
	}
	
	func successfullyLoggedIntoBank(result: KeepCheckingBankLoginResult) {
		if (result.bankRequiresSecurityQuestions) {
			self.performSegueWithIdentifier(bankLoginSecurityQuestionSegueIdentifier, sender: result);
		}
		else {
			let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true);
			hud.labelText = "Retrieving data";
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
				let refreshService = RefreshAllAccountDataService(auth: ConfigFactory.getAuth());
				refreshService.execute({ (result) in
					let saveDataService = SaveRefreshDataService();
					saveDataService.saveRefreshResult(result);
					
					dispatch_async(dispatch_get_main_queue(), {
						hud.hide(true);
						self.performSegueWithIdentifier(self.segueToSuccessfullyAddedAccount, sender: nil);
					});
				});
					
			})
		}
	}
	
	func errorLoggingIntoBank(result: KeepCheckingBankLoginResult) {
		if (result.message == "API Error") {
			self.performSegueWithIdentifier("segueToAPIError", sender: nil);
			return;
		}
		
		let alertController = UIAlertController(title: "Invalid Login", message: "Invalid credentials. Please try again", preferredStyle: UIAlertControllerStyle.Alert);
		alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in

		}));
		
		self.presentViewController(alertController, animated: true, completion: nil);
	}
	
    @IBAction func proceed(sender: AnyObject) {
		self.executeLogin();
	}
	
	deinit {
		print("Bank login view controller deallocated");
	}
}
