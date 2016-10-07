//
//  ITRLeftMenuController.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/18/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import ITRAirSideMenu
import MBProgressHUD

enum MenuOptions : String {
	case Menu = "Menu"
	case Dashboard = "Dashboard"
	case MyAccounts = "My Accounts"
	case SavingsPlan = "Savings Plan"
	case Settings = "Settings"
	case PaymentCalendar = "Payment Calendar"
	case About = "About"
	case ShareThrottle = "Share Throttle"
	case RateApp = "Rate App"
	case Logout = "Logout"
}

//My Dashboard / My Accounts / Savings Plan / Settings / Payment Calendar / About / Share Throttle / Rate App

class ITRLeftMenuController: UIViewController, UITableViewDataSource, UITableViewDelegate, ITRAirSideMenuDelegate {
	@IBOutlet var tableView: UITableView!
	let menuItems = [MenuOptions.Menu, MenuOptions.Dashboard, MenuOptions.MyAccounts, MenuOptions.SavingsPlan,
	                 MenuOptions.Settings, MenuOptions.PaymentCalendar, MenuOptions.About, MenuOptions.ShareThrottle, MenuOptions.RateApp, MenuOptions.Logout];
	
	let cellIdentifier = "Cell";
	let menuCellIdentifier = "MenuTitleCell";
	var selectedMenuIndex = 0;
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = Theme.getBackgroundColorForSidebar();
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentSideBar", name: NSNotificationName.presentSideBar.rawValue, object: nil);
		
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.backgroundColor = UIColor.clearColor();
		self.tableView.separatorColor = UIColor.clearColor();
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.menuItems.count;
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.selectedMenuIndex = indexPath.row;
		self.hideSideBar();
	}
	
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if (indexPath.row == 0) {
			let menuOption = self.menuItems[indexPath.row];
			let cell = tableView.dequeueReusableCellWithIdentifier(self.menuCellIdentifier);
			cell?.textLabel?.text = menuOption.rawValue;
			cell?.textLabel?.textColor = UIColor.whiteColor();
			cell?.backgroundColor = UIColor.clearColor();
			cell?.userInteractionEnabled = false;
			
			
			return cell!;
		}
		else {
			let menuOption = self.menuItems[indexPath.row];
			let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier);
			cell?.textLabel?.text = menuOption.rawValue;
			cell?.textLabel?.textColor = UIColor.whiteColor();
			cell?.backgroundColor = UIColor.clearColor();
			
			var cellSelectedBackgroundView = cell?.viewWithTag(5);
			if (cellSelectedBackgroundView == nil) {
				cellSelectedBackgroundView = UIView(frame: (cell?.frame)!);
				cellSelectedBackgroundView?.backgroundColor = UIColor(white: 0, alpha: 0.1);
				cell?.selectedBackgroundView = cellSelectedBackgroundView;
			}
			
			
			return cell!;
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 50;
	}
	
	func sideMenu(sideMenu: ITRAirSideMenu!, didHideMenuViewController menuViewController: UIViewController!) {
		let menuOption = self.menuItems[self.selectedMenuIndex];
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
		
		switch(menuOption) {
		case .Logout:
			MBProgressHUD.showHUDAddedTo((self.parentViewController?.view)!, animated: true);
			NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.userLoggedOut.rawValue, object: nil);
			break;
		case .Settings:
			let navigationController = StoryboardUtil.getSettingsVC();
			appDelegate.sideBarMenu?.setContentViewController(navigationController, animated: true);
			break;
		case .Dashboard:
			let navigationController = StoryboardUtil.getLoggedInVC();
			appDelegate.sideBarMenu?.setContentViewController(navigationController, animated: true);
			break;
		case .About:
			let navigationController = StoryboardUtil.getAboutVC();
			appDelegate.sideBarMenu?.setContentViewController(navigationController, animated: true);
			break;
		case .MyAccounts:
			let navigationController = StoryboardUtil.getAccountsVC()
			appDelegate.sideBarMenu?.setContentViewController(navigationController, animated: true);
			break;
		case .PaymentCalendar:
			let navigationController = StoryboardUtil.getCalendarVC()
			appDelegate.sideBarMenu?.setContentViewController(navigationController, animated: true);
			break;
		case .SavingsPlan:
			let vc = StoryboardUtil.getSavingsPlanVC();
			appDelegate.sideBarMenu?.setContentViewController(vc, animated: true);
			break;
        case .ShareThrottle:
            let textToShare = "Check out this new app Throttle!"
            
            let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            self.presentViewController(activityVC, animated: true, completion: nil)
		default:
			break;
		}
		
	}
}

//NSNotifcation Events
extension ITRLeftMenuController {
	func presentSideBar() {
		(UIApplication.sharedApplication().delegate as! AppDelegate).sideBarMenu?.presentLeftMenuViewController();
	}
	
	func hideSideBar() {
		(UIApplication.sharedApplication().delegate as! AppDelegate).sideBarMenu?.hideMenuViewController();
	}
}
