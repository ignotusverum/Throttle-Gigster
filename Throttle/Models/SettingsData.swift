//
//  SettingsData.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/29/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class SettingsData: NSObject {
  static let sharedSettingsData = SettingsData()
  
  static let settingCategories : [String] = ["Account settings", "Notification settings", "Contact support"];
  
  static let accountSettingCategories : [String] = ["Change email", "Change password", "Touch ID", "Pay By Lowest Balance"];
  
  static let notificationsSettingCategories : [String] = ["Payment Due Notifications"];
  static let kPushNotificationKey = "kPushNotificationKey"
  static let kPaymentDueNotificationsKey = "kPaymentDueNotificationsKey"
  
  static let notificationKeys: [String] = [kPaymentDueNotificationsKey]
  
  var notificationSettings: Dictionary<String, Bool> = [
    kPushNotificationKey:false,
    kPaymentDueNotificationsKey: false,
  ]
}
