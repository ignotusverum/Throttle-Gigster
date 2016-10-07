//
//  SignUpViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-21.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signupContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    @IBOutlet weak var emailValidationErrorLabel: UILabel!
    @IBOutlet weak var passwordValidationErrorLabel: UILabel!
    @IBOutlet weak var passwordConfirmationValidationErrorLabel: UILabel!
    
	@IBOutlet var privacyPolicyButton: UIButton!
	@IBOutlet var termsOfUseButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    private let throttleCommsManager = ThrottleCommunicationsManager.defaultManager
    private var keyboardOn = false
	var screenType : UIDeviceInfo.ScreenType?;
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textChanged"), name:UITextFieldTextDidChangeNotification, object: nil);
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupGestureRecognizers()
        
        //
        emailValidationErrorLabel.hidden = true
        passwordValidationErrorLabel.hidden = true
        passwordConfirmationValidationErrorLabel.hidden = true
		
		self.emailTextField.delegate = self;
		self.passwordTextField.delegate = self;
		self.passwordConfirmTextField.delegate = self;
		self.screenType = UIDeviceInfo.screenType();
		
		let privacyAttributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
		let privateAttributedText = NSAttributedString(string: self.privacyPolicyButton.titleLabel!.text!, attributes: privacyAttributes)
		self.privacyPolicyButton.setAttributedTitle(privateAttributedText, forState: UIControlState.Normal);
		
		let attributes = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
		let attributedText = NSAttributedString(string: self.termsOfUseButton.titleLabel!.text!, attributes: attributes)
		self.termsOfUseButton.setAttributedTitle(attributedText, forState: UIControlState.Normal);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self);
	}
	


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func signUp(sender: AnyObject) {
		self.executeSignUp();
	}
    
    @IBAction func signIn(sender: AnyObject) {
		self.executeSignIn();
    }
	
	func executeSignIn() {
		self.view.endEditing(true);
		self.keyboardOn = false;
		
		let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SignInViewControllerIdentifier") as! UINavigationController
		viewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		viewController.navigationBar.shadowImage = UIImage()
		viewController.navigationBar.translucent = true
		
		UIView.transitionFromView(UIApplication.sharedApplication().keyWindow!.rootViewController!.view, toView: viewController.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
			
			UIApplication.sharedApplication().keyWindow?.rootViewController = viewController
		})
	}
	
	func executeSignUp() {
		self.view.endEditing(true);
		self.keyboardOn = false;
		
		if !self.validateSignUpInputs() {
			return
		}
		
		self.throttleCommsManager.signUp(self.emailTextField.text!, password: self.passwordTextField.text!, completionHandler: { (user, error) -> Void in
			self.animateLogo(false)
			self.signUpButton.enabled = true
			
			if (nil == error) {
				UIAlertView(title: "Thank you", message: "Please check your email for a confirmation link", delegate: nil, cancelButtonTitle: "OK").show();

			} else {
				self.showSignUpCommunicationsError(error!)
			}
		} )
		
		signUpButton.enabled = false
		animateLogo(true)

	}
	
	//MARK: Keyboard events
	override func keyboardWillShow(notification: NSNotification) {
		self.hideLogo(true)
		if (self.screenType == .iPhone4)
		{
			let userInfo = notification.userInfo! as NSDictionary
			let keyboardFrameValue: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey)as! NSValue
			let rect = keyboardFrameValue.CGRectValue()
			
			var frame = self.view.frame;
			self.currentKeyboardHeight = rect.height;
			frame.origin.y = 100 - self.currentKeyboardHeight;
			self.view.frame = frame
			print(self.currentKeyboardHeight);
		}
		else
		{
			super.keyboardWillShow(notification);
		}
	}
	
	override func keyboardWillHide(notification: NSNotification) {
		self.hideLogo(false)
		super.keyboardWillHide(notification);
	}
    
    // MARK: - TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
		if (textField == self.emailTextField) {
			self.passwordTextField.becomeFirstResponder();
		} else if (textField == self.passwordTextField) {
			self.passwordConfirmTextField.becomeFirstResponder();
		}
		else {
			self.executeSignUp();
		}
		
		
        return true
    }
    
    func textChanged() {
        
        emailValidationErrorLabel.hidden = true
        passwordValidationErrorLabel.hidden = true
        passwordConfirmationValidationErrorLabel.hidden = true
    }
    
    // MARK: - Developer Methods

    private func hideLogo(hide: Bool) {
		if (self.logoImageView == nil) {return;}
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = (hide) ? 1 : 0
        animation.toValue = (hide) ? 0 : 1
        animation.duration = 0.5
        self.logoImageView.layer.addAnimation(animation, forKey: nil)
        self.logoImageView.hidden = hide
    }
    
    private func animateLogo(animate: Bool) {
        
        if !animate {
            
            logoImageView.layer.removeAnimationForKey("opacity")
            return
        }
        
        let animation = CABasicAnimation()
        animation.duration = 0.5
        animation.fromValue = NSNumber(float: 1)
        animation.toValue = NSNumber(float: 0)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeBoth
        animation.additive = false
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        logoImageView.layer.addAnimation(animation, forKey: "opacity")
    }
    
    private func setupGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func validateSignUpInputs() -> Bool {
        
        if self.emailTextField.text?.characters.count == 0 {
            
            emailValidationErrorLabel.text = NSLocalizedString("email required", comment: "")
            emailValidationErrorLabel.hidden = false
            return false
        }
        
        if !isValidEmail(emailTextField.text!) {
            
            emailValidationErrorLabel.text = NSLocalizedString("invalid email format", comment: "")
            emailValidationErrorLabel.hidden = false
            return false
        }
        
        if self.passwordTextField.text?.characters.count == 0 {
            
            passwordValidationErrorLabel.text = NSLocalizedString("password required", comment: "")
            passwordValidationErrorLabel.hidden = false
            return false
        }
        
        if self.passwordConfirmTextField.text?.characters.count == 0 {
            
            passwordConfirmationValidationErrorLabel.text = NSLocalizedString("confirm password", comment: "")
            passwordConfirmationValidationErrorLabel.hidden = false
            return false
        }
        
        if self.passwordTextField.text != self.passwordConfirmTextField.text {
        
            passwordConfirmationValidationErrorLabel.text = NSLocalizedString("passwords didn't match", comment: "")
            passwordConfirmationValidationErrorLabel.hidden = false
            return false
        }
        
        return true
    }
    
	@IBAction func passwordQuestionButtonTapped(sender: AnyObject) {
		let alertController = AlertUtil.getSimpleAlert("TODO", message: "Need to know what happens when this button is tapped.");
		self.presentViewController(alertController, animated: true, completion: nil);
	}
	
	@IBAction func privatePolicyTapped(sender: AnyObject) {
		let vc = StoryboardUtil.getPrivacyPolicyVC();
		self.presentViewController(vc, animated: true, completion: nil);
	}
	
	@IBAction func alreadyAUserLogin(sender: AnyObject) {
		self.executeSignIn();
	}
	
	@IBAction func termsOfUseTapped(sender: AnyObject) {
		let vc = StoryboardUtil.getTermsAndConditionsVC();
		self.presentViewController(vc, animated: true, completion: nil);
	}
	
    private func showSignUpCommunicationsError(error: NSError) {
        
        let alertController = UIAlertController(title: "Sign up Error", message: error.localizedDescription, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Gestures
    func tap(recognizer: UITapGestureRecognizer) {
    
        if !self.keyboardOn {

            return
        }
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordConfirmTextField.resignFirstResponder()
    }
}
