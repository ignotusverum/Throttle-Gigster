//
//  AppDelegate.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-20.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import ITRAirSideMenu
import AWSSNS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
	var sideBarMenu : ITRAirSideMenu?;
  var deviceToken:String!
  let auth = ConfigFactory.getAuth()
    var firstTime:Bool = false;
  
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      self.applyDefaultStyles();

      let userDefaults = NSUserDefaults.standardUserDefaults();
      if (userDefaults.objectForKey("FirstRun") == nil) {
        self.auth.removeAuthenticatedUserData();
        userDefaults.setBool(true, forKey: "FirstRun");
        self.firstTime = true
        userDefaults.synchronize();
      }
      
      self.registerForPushNotifications(application)
        
      // clear notification badge count upon launch
      application.applicationIconBadgeNumber = 0
        
      let settingsService = SettingsService(auth: self.auth);
      
      if (self.auth.isUserLoggedIn()) {
        if (!self.auth.getAuthenticatedUsingTouchID() && settingsService.isTouchIDEnabledOrSet()) {
          self.changeRootControllerToSignInController()
          let touchIdAuthUtil = TouchIDAuthenticationUtil();
          
          touchIdAuthUtil.authenticate({ (response) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
              switch(response) {
              case .Error:
                NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.userLoggedOut.rawValue, object: nil);
                break;
              case .PasswordFallback:
                self.performTouchIdFallbackProcedure();
                break;
              case .Success:
                self.auth.setAuthenticatedUsingTouchID(true);
                self.changeRootControllerToLoggedInController()
                break;
              }
              
            };
          });
        } else {
          //If the user turned on touch ID from the settings, we don't want to show this pop up until they open the app again
          self.auth.setAuthenticatedUsingTouchID(true);
          self.changeRootControllerToLoggedInController();
        }
      }
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.userLoggedOut), name: NSNotificationName.userLoggedOut.rawValue, object: nil);
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.userLoggedIn), name: NSNotificationName.userLoggedIn.rawValue, object: nil);
      
      // Override point for customization after application launch.
      Fabric.with([Crashlytics.self])

      return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		NSUserDefaults.setDateUserLeftTheApp(NSDate());
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
	
	private func applyDefaultStyles() {
		
		
		UINavigationBar.appearance().translucent = true
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "KohinoorBangla-Semibold", size: 14)!]
		UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "KohinoorBangla-Regular", size: 14)!], forState: .Normal)
		UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont(name: "KohinoorBangla-Regular", size: 14)!], forState: .Normal)
	}
  
  private func performTouchIdFallbackProcedure() {
    let alertController = UIAlertController(title: "Enter Password", message: "Enter your password below", preferredStyle: UIAlertControllerStyle.Alert);
    alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
      textField.placeholder = "Password";
      textField.secureTextEntry = true;
    };
    
    alertController.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
      let textField = alertController.textFields!.first!;
      let authenticatedUser = self.auth.getAuthenticatedUser()!;
      
      if (authenticatedUser.password == textField.text) {
        self.auth.setAuthenticatedUsingTouchID(true);
        self.changeRootControllerToLoggedInController()
        alertController.dismissViewControllerAnimated(true, completion: nil);
      }
      else {
        //invalid password
        self.performTouchIdFallbackProcedure();
      }
    }));
    
    alertController.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
      alertController.dismissViewControllerAnimated(true, completion: nil);
      NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.userLoggedOut.rawValue, object: nil);
    }));
    
    self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil);
  }
}


//Handle the change of root view controller, triggered by logging in and logging out
extension AppDelegate {
	func userLoggedIn() {
		self.changeRootControllerToLoggedInController();
	}
	
	func userLoggedOut() {
		let auth = ConfigFactory.getAuth();
		let service = LogoutService(auth: auth);
		service.execute { (success) -> Void in
			self.changeRootControllerToSignInController();
		};
	}
	
	func changeRootControllerToLoggedInController() {
		let navigationController = StoryboardUtil.getLoggedInVC();
		let customSideBarController = StoryboardUtil.getSidebarVC();
		
		let sideBarController = ITRAirSideMenu(contentViewController: navigationController, leftMenuViewController: customSideBarController);
		sideBarController.view.backgroundColor = Theme.getBackgroundColorForSidebar();
		sideBarController.delegate = customSideBarController;

		self.sideBarMenu = sideBarController;
		if let _ = UIApplication.sharedApplication().keyWindow, let currentRootView = UIApplication.sharedApplication().keyWindow!.rootViewController {
			UIView.transitionFromView(currentRootView.view, toView: sideBarController.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
				UIApplication.sharedApplication().keyWindow?.rootViewController = sideBarController;
			})
		}
		else {
			self.window?.rootViewController = sideBarController;
			self.window?.makeKeyAndVisible();
		}
	}
	
	func changeRootControllerToSignInController() {
		let viewController = StoryboardUtil.getSignInVC();
		viewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
		viewController.navigationBar.shadowImage = UIImage()
		viewController.navigationBar.translucent = true
		
    if let _ = UIApplication.sharedApplication().keyWindow, let currentRootView = UIApplication.sharedApplication().keyWindow!.rootViewController {
      UIView.transitionFromView(currentRootView.view, toView: viewController.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (finished) -> Void in
        UIApplication.sharedApplication().keyWindow?.rootViewController = viewController;
      })
    }
    else {
      self.window?.rootViewController = viewController;
      self.window?.makeKeyAndVisible();
    }
	}
	
  
  // Push notifications
  func registerForPushNotifications(application: UIApplication) {
    let current = application.currentUserNotificationSettings()
    print(current?.types)
    if (current?.types == UIUserNotificationType.None) {
      if (self.firstTime == true) {
        print("First launch")
        let notificationSettings = UIUserNotificationSettings(
          forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
      } else {
        print("User didn't allowed notifications before")
      }
    } else {
      print("User allowed notifications before")
      application.registerUserNotificationSettings(current!)
    }
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
//      application.registerForRemoteNotifications()
      let sharedSettingsData = SettingsData.sharedSettingsData
      sharedSettingsData.notificationSettings[SettingsData.kPushNotificationKey] = true
    } else {
      // Denied notifications
      let userDefaults = NSUserDefaults.standardUserDefaults();
      // If there's an old notification token, remove it
      if (userDefaults.objectForKey("NotificationToken") != nil) {
        userDefaults.removeObjectForKey("NotificationToken")
        userDefaults.synchronize();
      }
      let sharedSettingsData = SettingsData.sharedSettingsData
      sharedSettingsData.notificationSettings[SettingsData.kPushNotificationKey] = false
    }
  }
}

