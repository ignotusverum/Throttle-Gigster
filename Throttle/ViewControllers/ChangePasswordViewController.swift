//
//  ChangePasswordViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/29/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController, UITextFieldDelegate {
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var emailTextField:UITextField!
      @IBOutlet weak var emailValidationErrorLabel: UILabel!
  
  var errorMessage:String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    emailValidationErrorLabel.hidden = true
    // Do any additional setup after loading the view.
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldChanged"), name:UITextFieldTextDidChangeNotification, object: nil)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  @IBAction func requestPassChangeButtonPressed(sender: AnyObject) {
    if (!hasEmail()) {
      if (self.errorMessage.characters.count > 0) {
        emailValidationErrorLabel.text = self.errorMessage
        emailValidationErrorLabel.hidden = false
      }
    } else {
       self.executeChangePassword()
    }
    
  }
  
  private func hasEmail() -> Bool {
    guard let text = self.emailTextField.text else {
      return false
    }
    
    if (text.characters.count <= 0) {
      self.errorMessage = "Email address required"
      return false
    }
    
    if (!isValidEmail(text))
    {
      self.errorMessage = "Valid email required"
      return false
    }
    return true
  }
  
  func executeChangePassword() {
    let auth = ConfigFactory.getAuth();
    let changePasswordService = ChangePasswordService(auth: auth)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      changePasswordService.execute(self.emailTextField.text!, completionHandler:  { (success) -> Void in
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if (success) {
            self.successfullyChangedPassword();
          }
          else {
            self.errorChangingPassword();
          }
        });
      })
    };
  }
  
  func successfullyChangedPassword() {
    print("Success sending password change email")
    for controller: UIViewController in (self.navigationController?.viewControllers)! as [UIViewController] {
      if controller.isKindOfClass(SettingsViewController) {
        let settingsVC = controller as! SettingsViewController
        settingsVC.showPasswordRequestChangeConfirmation()
        self.navigationController!.popToViewController(controller, animated: true)
      }
    }
  }
  
  func errorChangingPassword() {
    print("Error requesting password change")
    let errorAlertController = UIAlertController(title: "Error", message: "Error sending password reset email", preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    })
    errorAlertController.addAction(okAction)
    self.presentViewController(errorAlertController, animated: true, completion: nil)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let touch = touches.first
    
    if (touch!.view != self.emailTextField && self.emailTextField.isFirstResponder()) {
      self.emailTextField.resignFirstResponder()
    }
    super.touchesBegan(touches, withEvent: event)
  }
  
  // MARK: - TextField Delegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if (textField == self.emailTextField) {
      self.executeChangePassword()
    }
  
    return true
  }
  
  func textFieldChanged() {
    emailValidationErrorLabel.hidden = true
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
