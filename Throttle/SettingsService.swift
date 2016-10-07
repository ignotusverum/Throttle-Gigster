//
//  SettingsService.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class SettingsService: NSObject {
  let auth : AuthProtocol;
  
  init(auth: AuthProtocol) {
    self.auth = auth;
  }

  let kTouchIDEnabled = "touchIDEnabled"
  func setTouchIDEnabled(enabled:Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults();
      userDefaults.setBool(enabled, forKey: kTouchIDEnabled);
      userDefaults.synchronize();
  }
  
  func isTouchIDEnabledOrSet() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults();
    if let enabled = userDefaults.objectForKey(kTouchIDEnabled) {
      return enabled as! Bool
    }
    // default false
    self.setTouchIDEnabled(false)
    return false
  }
}
