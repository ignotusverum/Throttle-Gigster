//
//  Config.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/17/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

enum NSNotificationName : String {
	case userLoggedOut = "userLoggedOut"
	case userLoggedIn = "userLoggedIn"
	case presentSideBar = "PresentSideBar"
	case beginWelcomeButtonAnimation = "BeginAnimation"
	case userAccountDataRefreshed = "userAccountDataRefreshed"
}

class Config {
	static func getWebAPIURL() -> String {
		return NSBundle.mainBundle().objectForInfoDictionaryKey("Root API URL") as! String;
	}
	
	static func getMainStoryboard() -> UIStoryboard {
		return UIStoryboard(name: "Main", bundle: nil);
	}
	
	static func getSettingsStoryboard() -> UIStoryboard {
		return UIStoryboard(name: "Settings", bundle: nil);
	}
  
  static func getSecondaryStoryboard() -> UIStoryboard {
    return UIStoryboard(name: "Secondary", bundle: nil);
  }
}

class ConfigFactory {
	static func getAuth() -> AuthProtocol {
		return Auth();
	}
}