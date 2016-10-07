//
//  NotificationsViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/29/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  let notificationsCellIdentifier = "notificationsCellIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()
      // Hide the cell separator lines for empty cells
      let footerPlaceholder = UIView()
      footerPlaceholder.backgroundColor = UIColor(red: 9.0/255.0, green: 71.0/255.0, blue: 118.0/255.0, alpha: 1)
      self.tableView.tableFooterView = footerPlaceholder
      self.tableView.backgroundColor = tableViewCellDarkerBlue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension NotificationsViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let sharedSettingsData = SettingsData.sharedSettingsData
    return (sharedSettingsData.notificationSettings[SettingsData.kPushNotificationKey] == true) ? 2 : 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 1
    } else if (section == 1) {
      return SettingsData.notificationsSettingCategories.count
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let sharedSettingsData = SettingsData.sharedSettingsData
    let cell = tableView.dequeueReusableCellWithIdentifier(notificationsCellIdentifier, forIndexPath: indexPath)
    if (indexPath.section == 0) {
      cell.textLabel?.text = "Push notifications"
      let pushNotifSwitch = UISwitch()
      pushNotifSwitch.addTarget(self, action: "toggledPushNotifications:", forControlEvents: UIControlEvents.ValueChanged)
      pushNotifSwitch.setOn(sharedSettingsData.notificationSettings[SettingsData.kPushNotificationKey]!, animated: false)
      cell.accessoryView = pushNotifSwitch
      
      cell.backgroundColor = UIColor(red:11/255, green:84/255, blue:137/255, alpha:1)
      
    } else {
      cell.textLabel?.text = SettingsData.notificationsSettingCategories[indexPath.row]
      
      let notifSwitch = UISwitch()
      // To retrieve which switch this is in the action
      notifSwitch.tag = indexPath.row
      notifSwitch.setOn(sharedSettingsData.notificationSettings[SettingsData.notificationKeys[indexPath.row]]!, animated: false)
      notifSwitch.addTarget(self, action: "toggledSettingNotification:", forControlEvents: UIControlEvents.ValueChanged)
      cell.accessoryView = notifSwitch
      cell.backgroundColor = (indexPath.row % 2 != 0) ? UIColor(red:11/255, green:84/255, blue:137/255, alpha:1) : UIColor(red:10/255, green:74/255, blue:125/255, alpha:1)
    }
    return cell
  }
  
  func toggledPushNotifications(sender:UISwitch) {
    let sharedSettingsData = SettingsData.sharedSettingsData
    sharedSettingsData.notificationSettings[SettingsData.kPushNotificationKey] = sender.on
    
    let notificationsService = NotificationsService(auth: ConfigFactory.getAuth())
    if (sender.on) {
      notificationsService.clearAndRegisterAllNotifications()
    } else {
      notificationsService.clearRegisteredNotifications()
      for key in SettingsData.notificationKeys {
        sharedSettingsData.notificationSettings[key] = false
      }
    
    }
    self.tableView.reloadData()
  }
  
  func toggledSettingNotification(sender:UISwitch) {
    let settingIndex = sender.tag
    let sharedSettingsData = SettingsData.sharedSettingsData
    sharedSettingsData.notificationSettings[SettingsData.notificationKeys[settingIndex]] = sender.on
    
    let notificationsService = NotificationsService(auth: ConfigFactory.getAuth())
    if (sender.on) {
      // only register this type
      notificationsService.clearAndRegisterAllNotifications()
    } else {
      notificationsService.clearRegisteredNotifications()
    }
  }
  
}