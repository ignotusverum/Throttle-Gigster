//
//  AuthenticationViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-19.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signinContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailValidationErrorLabel: UILabel!
    @IBOutlet weak var passwordValidationErrorLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    let throttleCommsManager = ThrottleCommunicationsManager.defaultManager
    var screenType: UIDeviceInfo.ScreenType?
    var originalViewFrameOriginY: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textChanged"), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupGestureRecognizers()
        
        emailValidationErrorLabel.hidden = true
        passwordValidationErrorLabel.hidden = true
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.screenType = UIDeviceInfo.screenType()
        self.originalViewFrameOriginY = self.view.frame.origin.y
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        self.hideLogo(true)
        if (self.screenType == .iPhone4) {
            let userInfo = notification.userInfo! as NSDictionary
            let keyboardFrameValue: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
            let rect = keyboardFrameValue.CGRectValue()
            
            var frame = self.view.frame
            self.currentKeyboardHeight = rect.height
            frame.origin.y = 100 - self.currentKeyboardHeight
            self.view.frame = frame
            print(self.currentKeyboardHeight)
        }
        else {
            super.keyboardWillShow(notification)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.hideLogo(false)
        super.keyboardWillHide(notification)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func signIn(sender: AnyObject) {
        self.executeSignIn()
    }
    
    @IBAction func signUp(sender: AnyObject) {
        self.executeSignUp()
    }
    
    @IBAction func passwordQuestionButtonTapped(sender: AnyObject) {
        let alertController = AlertUtil.getSimpleAlert("TODO", message: "Need to know what happens when this button is tapped.")
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func executeSignIn() {
        self.view.endEditing(true)
        
        if !self.validateSignInInputs() {
            
            return
        }
        
        self.throttleCommsManager.signIn(self.emailTextField.text!, password: self.passwordTextField.text!, auth: ConfigFactory.getAuth(), completionHandler: { (user, error) -> Void in
            
            if (nil == error) {
                let refreshService = RefreshAllAccountDataService(auth: ConfigFactory.getAuth())
                refreshService.execute({ (result) in
                    let saveDataService = SaveRefreshDataService()
                    saveDataService.saveRefreshResult(result)
                    
                    // Fetch user payment preferences
                    let paymentPreferenceService = GetMonthlyPaymentService(auth: ConfigFactory.getAuth())
                    paymentPreferenceService.execute({ (result) in
                        if let result = result {
                            NSUserDefaults.setTotalMonthlyMinimumPayment(result)
                        } else {
                            // We didn't have a saved minimum value.
                            NSUserDefaults.setTotalMonthlyMinimumPayment(0)
                        }
                        
                        self.animateLogo(false)
                        self.signInButton.enabled = true
                        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.userLoggedIn.rawValue, object: nil, userInfo: nil)
                    })
                })
                return
            }
            
            self.animateLogo(false)
            self.signInButton.enabled = true
            
            if (nil == error) {
                NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.userLoggedIn.rawValue, object: nil, userInfo: nil)
            } else {
                self.showSignInCommunicationsError(error!)
            }
            
        })
        
        self.signInButton.enabled = false
        animateLogo(true)
    }
    
    func executeSignUp() {
        self.view.endEditing(true)
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpViewControllerIdentifier") as! SignUpViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.navigationController?.navigationBarHidden = true
        
        UIView.transitionFromView(UIApplication.sharedApplication().keyWindow!.rootViewController!.view, toView: navigationController.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
            
            UIApplication.sharedApplication().keyWindow?.rootViewController = navigationController
        })
    }
    
    func saveAccountDataResult() {
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.passwordTextField.becomeFirstResponder()
        }
        else {
            self.executeSignIn()
        }
        return true
    }
    
    func textChanged() {
        
        emailValidationErrorLabel.hidden = true
        passwordValidationErrorLabel.hidden = true
    }
    
    // MARK: - Developer Methods
    private func hideLogo(hide: Bool) {
        if (self.logoImageView == nil) { return; }
        
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
    
    private func validateSignInInputs() -> Bool {
        
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
        
        return true
    }
    
    private func showSignInCommunicationsError(error: NSError) {
        let alertController = UIAlertController(title: "Invalid Credentials", message: "Invalid username or password", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Gestures
    func tap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
}
