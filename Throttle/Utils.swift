//
//  Utils.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-29.
//  Copyright © 2015 Gigster. All rights reserved.
//

import Foundation
import UIKit


public func printFonts() {
    let fontFamilyNames = UIFont.familyNames()
    for familyName in fontFamilyNames {
        print("------------------------------")
        print("Font Family Name = [\(familyName)]")
        let names = UIFont.fontNamesForFamilyName(familyName)
        print("\(names)")
    }
}

public func isValidEmail(email:String) -> Bool {

    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(email)
}

class UIDeviceInfo
{
	enum ScreenType: String {
		case iPhone4
		case iPhone5
		case iPhone6
		case iPhone6Plus
		case Unknown
	}
	
	static func screenType() -> ScreenType? {
		if (UIDevice().userInterfaceIdiom == .Phone) {
			switch UIScreen.mainScreen().nativeBounds.height {
			case 960:
				return .iPhone4
			case 1136:
				return .iPhone5
			case 1334:
				return .iPhone6
			case 2208:
				return .iPhone6Plus
			default:
				return nil
			}
		}
		
		return nil;
	}
}

class AlertUtil
{
	static func getSimpleAlert(title: String, message: String) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
		alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
		return alertController;
	}
}

public func tableViewCellDarkerBlue() -> UIColor {
  return UIColor(red:11/255, green:84/255, blue:137/255, alpha:1)
}

public func tableViewCellLighterBlue() -> UIColor {
  return UIColor(red:10/255, green:74/255, blue:125/255, alpha:1)
}

