//
//  Theme.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/26/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class Theme: NSObject {
	static func blueBarColor() -> UIColor {
		return UIColor(red: 0/255, green: 172/255, blue: 255/255, alpha: 1);
	}
	
	static func blueBarTextColor() -> UIColor {
		return UIColor.whiteColor();
	}
	
	static func greenBarColor() -> UIColor {
		return UIColor(red: 0.28, green: 0.73, blue: 0.33, alpha: 1);
	}
	
	static func greenBarTextColor() -> UIColor {
		return UIColor.whiteColor();
	}
	
	static func darkBlueBarColor() -> UIColor {
		return UIColor(red: 0.0272, green: 0.2381, blue: 0.4101, alpha: 1.0);
	}
	
	static func darkBlueTextColor() -> UIColor {
		return UIColor.whiteColor();
	}
	
	static func redBarColor() -> UIColor {
		return UIColor(red: 0.9478, green: 0.157, blue: 0.1728, alpha: 1.0);
	}
	
	static func redBarTextColor() -> UIColor {
		return UIColor.whiteColor();
	}
	
	static func getBackgroundColorForSidebar() -> UIColor {
		return UIColor ( red: 0.0588, green: 0.2235, blue: 0.3843, alpha: 1.0 );
	}
	
	static func getConfirmAccountTableBackgroundColor1() -> UIColor {
		return UIColor(red:10/255, green:74/255, blue:125/255, alpha:1);
	}
	
	static func getConfirmAccountTableBackgroundColor2() -> UIColor {
		return UIColor(red:11/255, green:84/255, blue:137/255, alpha:1);
	}
	
	
	
	static func dashboardCardTotalInterestBackgroundColor() -> UIColor {
		return UIColor(red: 24.9/255, green: 150.3/255, blue: 244.6/255, alpha: 1.0);
	}
	
	static func dashboardCardTotalBalanceBackgroundColor() -> UIColor {
		return UIColor ( red: 0.3922, green: 0.7529, blue: 0.3725, alpha: 1.0 );
	}
	
	static func dashboardCardGrandTotalBackgroundColor() -> UIColor {
		return UIColor ( red: 0.9882, green: 0.5765, blue: 0.2078, alpha: 1.0 );
	}
	
	static func dashboardCardTotalMonthlyPaymentsBackgroundColor() -> UIColor {
		return UIColor ( red: 0.4392, green: 0.6588, blue: 0.7373, alpha: 1.0 );
	}
}
