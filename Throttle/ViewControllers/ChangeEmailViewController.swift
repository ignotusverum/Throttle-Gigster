//
//  ChangeEmailViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/28/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class ChangeEmailViewController: BaseViewController {
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var lineView: UIView!
  @IBOutlet weak var topHeaderView: UIView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var bottomConstraintOfSaveButton: NSLayoutConstraint!
  @IBOutlet weak var headerToEmailFieldConstraint: NSLayoutConstraint!
  @IBOutlet weak var textFieldToButtonConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var emailValidationErrorLabel: UILabel!
  
  var errorMessage:String = ""
  
  var updatedEmail:Bool = false
  var screenType : UIDeviceInfo.ScreenType?;
  
  var textFieldToButtonHardConstraint:NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.screenType = UIDeviceInfo.screenType();
    
    self.textFieldToButtonHardConstraint = NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: emailTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 60)
    self.textFieldToButtonHardConstraint.priority = UILayoutPriorityRequired
    
    emailValidationErrorLabel.hidden = true
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldChanged"), name:UITextFieldTextDidChangeNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if (self.screenType == .iPhone4) {
      self.bottomConstraintOfSaveButton.constant = 10
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func returnTextField(sender: AnyObject) {
    updateEmail()
  }
  @IBAction func saveButtonSelected(sender: AnyObject) {
    updateEmail()
  }
  
  func updateEmail() {
      if (self.hasEmail() == true) {
        self.executeChangeEmail()
      } else {
        emailValidationErrorLabel.text = self.errorMessage
        emailValidationErrorLabel.hidden = false
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
  
  func executeChangeEmail() {
    
    let auth = ConfigFactory.getAuth();
    let changeEmailService = ChangeEmailService(auth: auth)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      changeEmailService.execute(self.emailTextField.text!, completionHandler: { (success) -> Void in
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          
          if (success) {
            self.successfullyChangedEmail();
          }
          else {
            self.errorChangingEmail();
          }
          
        });
      })
    };
    updatedEmail = true;
  }
  
  func successfullyChangedEmail() {
    print("Success changing email")
    for controller: UIViewController in (self.navigationController?.viewControllers)! as [UIViewController] {
      if controller.isKindOfClass(SettingsViewController) {
        let settingsVC = controller as! SettingsViewController
        settingsVC.showEmailChangeConfirmation(self.emailTextField.text!)
        self.navigationController!.popToViewController(controller, animated: true)
      }
    }
  }
  
  func errorChangingEmail() {
    print("Error requesting email change")
    let errorAlertController = UIAlertController(title: "Error", message: "Error sending email reset", preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    })
    errorAlertController.addAction(okAction)
    self.presentViewController(errorAlertController, animated: true, completion: nil)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    let touch = event?.allTouches()?.first
    if (self.emailTextField.isFirstResponder() && touch!.view != self.emailTextField) {
      self.emailTextField.resignFirstResponder()
    }
  }
  
  func textFieldChanged() {
    emailValidationErrorLabel.hidden = true
  }
  
  //MARK: - Keyboard events
  override func keyboardWillShow(notification: NSNotification) {
    super.keyboardWillShow(notification)
    self.view.removeConstraint(self.textFieldToButtonConstraint)
    self.view.addConstraint(self.textFieldToButtonHardConstraint)
    self.view.removeConstraint(self.headerToEmailFieldConstraint)
  }
  
  override func keyboardWillHide(notification: NSNotification) {
    super.keyboardWillHide(notification)
    self.view.removeConstraint(self.textFieldToButtonHardConstraint)
    self.view.addConstraint(self.textFieldToButtonConstraint)
    self.view.addConstraint(self.headerToEmailFieldConstraint)
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
