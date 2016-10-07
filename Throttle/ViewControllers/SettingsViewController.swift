//
//  SettingsViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import TSMessages
import MessageUI

class SettingsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var throttleLogoImageView: UIImageView!
  @IBOutlet weak var changedEmailView: UIView!
  
  @IBOutlet weak var changedEmailTextField: UITextField!
  
  let settingsCellIdentifier = "settingsCellIdentifier";
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Hide the cell separator lines for empty cells
    self.tableView.tableFooterView = UIView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func menuButtonTapped(sender: AnyObject) {
    NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.presentSideBar.rawValue, object: nil);
  }
  
  func showEmailChangeConfirmation(email:String) {
    self.view.backgroundColor = UIColor(red: 0.0/255.0, green: 195.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    self.throttleLogoImageView.image = UIImage(named:"logotype-white")
    self.changedEmailView.hidden = false
    self.changedEmailTextField.text = email
    showBanner("Your email was changed successfully")
  }
  
  func showPasswordRequestChangeConfirmation() {
    showBanner("Password reset email sent")
  }
  
  func showEmailSentConfirmation() {
    showBanner("Your message was sent successfully")
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    changedEmailView.hidden = true
    self.view.backgroundColor = UIColor.whiteColor()
    self.throttleLogoImageView.image = UIImage(named:"logotype-blue")
  }
  
  func showBanner(message:String) {
    // Displays starting at the bottom of the nav bar, but overlaps
    TSMessage.setDefaultViewController(self.navigationController)
    // Without it, displays from the very top
    TSMessage.showNotificationWithTitle(message, type: TSMessageNotificationType.Success)
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

extension SettingsViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SettingsData.settingCategories.count
    //    return settingCategories.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(settingsCellIdentifier, forIndexPath: indexPath)
    
    cell.textLabel?.text = SettingsData.settingCategories[indexPath.row];
    
    cell.backgroundColor = (indexPath.row % 2 != 0) ? UIColor(red:11/255, green:84/255, blue:137/255, alpha:1) : UIColor(red:10/255, green:74/255, blue:125/255, alpha:1)
    
    return cell
  }
}

extension SettingsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Selected" , SettingsData.settingCategories[indexPath.row])
    switch (indexPath.row) {
    case 0:
      self.performSegueWithIdentifier("accountSettingsSegue", sender: nil)
      break
    case 1:
      self.performSegueWithIdentifier("notificationsSegue", sender: nil)
      break
    case 2:
      sendEmail()
      break
    default:
      break
    }
  }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
  func sendEmail() {
    if !MFMailComposeViewController.canSendMail() {
      print("Mail services are not available")
      return
    } else {
      let mailComposeVC = MFMailComposeViewController()
      
      mailComposeVC.mailComposeDelegate = self;
      mailComposeVC.setToRecipients(["support@throttle.me"])
      self.presentViewController(mailComposeVC, animated: true, completion: nil)
    }
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    switch (result)
    {
    case .Cancelled:
     print("Mail cancelled");
      break;
    case .Saved:
      print("Mail saved");
      break;
    case .Sent:
      print("Mail sent");
      showEmailSentConfirmation()
      break;
    case .Failed:
      print("Mail sent failure: ", error?.localizedDescription);
      break;
    default:
      break;
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
