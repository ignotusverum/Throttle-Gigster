//
//  StoryboardUtil.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class StoryboardUtil: NSObject {
	static func getSidebarVC() -> ITRLeftMenuController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("sideBarMenu") as! ITRLeftMenuController;
	}
	
	static func getLoggedInVC() -> UINavigationController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("loggedInVC") as! UINavigationController;
	}
	
	static func getSignInVC() -> UINavigationController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("SignInViewControllerIdentifier") as! UINavigationController;
	}
	
	static func getSettingsVC() -> UINavigationController {
		return Config.getSettingsStoryboard().instantiateViewControllerWithIdentifier("settingsVC") as! UINavigationController;
	}
	
	static func getAboutVC() -> UINavigationController {
		return Config.getSettingsStoryboard().instantiateViewControllerWithIdentifier("aboutVC") as! UINavigationController;
	}
	
	static func getAccountsVC() -> UINavigationController {
		return Config.getSecondaryStoryboard().instantiateViewControllerWithIdentifier("accountsVC") as! UINavigationController;
	}
	
	static func getCalendarVC() -> UINavigationController {
		return Config.getSecondaryStoryboard().instantiateViewControllerWithIdentifier("calendarVC") as! UINavigationController;
	}
	
	static func getBankSearchVC() -> BankSearchViewController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("bankSearchVC") as! BankSearchViewController
	}
	
	static func getSavingsPlanVC() -> UINavigationController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("savingsPlanVC") as! UINavigationController
	}
	
	static func getTermsAndConditionsVC() -> UIViewController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("TermsAndConditionsVC");
	}
	
	static func getPrivacyPolicyVC() -> UIViewController {
		return Config.getMainStoryboard().instantiateViewControllerWithIdentifier("PrivacyPolicyVC");
	}
}
