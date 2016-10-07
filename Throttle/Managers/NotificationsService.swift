//
//  NotificationObject.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 4/13/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import AWSSNS
import RealmSwift

class NotificationsService: NSObject {
  let auth : AuthProtocol;
  
  init(auth: AuthProtocol) {
    self.auth = auth;
  }
  

  func clearRegisteredNotifications() {
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }
  
  func clearAndRegisterAllNotifications() {
    self.clearRegisteredNotifications()
    self.registerReminderNotifications()
     // for when there are multiple types of notifications in the future, add them here
  }
  
  func registerReminderNotifications() {
    var accounts = [UserAccountEntity]()
    do {
      let realm = try Realm.getEncryptedInstance();
      let realmAccounts = realm.objects(UserAccountEntity)
      accounts = Array(realmAccounts)
      
      print(accounts.count , "accounts")
      print(accounts)
    }
    catch {
      print(error)
    }
    
    for account in accounts {
      print(account.dayOfMonthWhenDue)
      // is a loan with a payment date
      if (account.dayOfMonthWhenDue != 0) {
        self.executeNotificationRegistration(account)
      }
    }
  }
  
  func executeNotificationRegistration(account:UserAccountEntity) {
    let sharedSettingsData = SettingsData.sharedSettingsData
    if (sharedSettingsData.notificationSettings[SettingsData.kPaymentDueNotificationsKey] == true) {
      
      let calendar = NSCalendar.autoupdatingCurrentCalendar()
      let today = NSDate()
      
      let todayComponents = NSCalendar.currentCalendar().components([.Month, .Year], fromDate: today)
      
      let dateComps = NSDateComponents()
      dateComps.day = account.dayOfMonthWhenDue
      
      dateComps.month = todayComponents.month
      dateComps.year = todayComponents.year
      dateComps.hour = 12
      dateComps.minute = 0
      
      let itemDate = calendar.dateFromComponents(dateComps);
      let localNotif = UILocalNotification()
      localNotif.fireDate = itemDate
      localNotif.timeZone = NSTimeZone.defaultTimeZone()
      localNotif.alertBody = String(format: "Payment for %@ due tomorrow", account.accountName)
      localNotif.alertTitle = String(format: "Payment Reminder", account.accountName)
      localNotif.soundName = UILocalNotificationDefaultSoundName
      localNotif.applicationIconBadgeNumber = 1
      localNotif.repeatInterval = NSCalendarUnit.Month
      UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
  }
}
