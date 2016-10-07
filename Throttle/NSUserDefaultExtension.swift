//
//  NSUserDefaultExtension.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

let userDefaultTotalMonthlyMinimumPaymentId = "userDefaultTotalMonthlyMinimumPayment";
let userDefaultCalculationAlgorithm = "userDefaultCalculationAlgorithm";
let userDefaultDateUserLeftAppId = "userDefaultDateUserLeftAppId";

extension NSUserDefaults {
	static func setTotalMonthlyMinimumPayment(minPayment: Int) {
		let defaults = NSUserDefaults.standardUserDefaults();
		defaults.setObject(minPayment, forKey: userDefaultTotalMonthlyMinimumPaymentId);
		defaults.synchronize();
	}
	
	static func getTotalMonthlyMinimumPayment() -> Int {
		if let minPayment = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultTotalMonthlyMinimumPaymentId) as? Int {
			return minPayment;
		}
		
		return 0;
	}
    
    static func setCalculationAlgorithm(algorithm: CalculationAlgorithm?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(algorithm?.rawValue, forKey: userDefaultCalculationAlgorithm)
    }
    
    static func getCalculationAlgorithm() -> CalculationAlgorithm {
        if let encodedAlgorithm = NSUserDefaults.standardUserDefaults().stringForKey(userDefaultCalculationAlgorithm), decodedAlgorithm = CalculationAlgorithm(rawValue: encodedAlgorithm) {
            return decodedAlgorithm
        } else {
            let defaultValue = CalculationAlgorithm.LowestBalanceFirst
            setCalculationAlgorithm(defaultValue)
            return defaultValue
        }
    }
	
	static func setDateUserLeftTheApp(date: NSDate) {
		let defaults = NSUserDefaults.standardUserDefaults();
		defaults.setObject(date, forKey: userDefaultDateUserLeftAppId);
		defaults.synchronize();
	}
	
	static func getDateUserLeftTheApp() -> NSDate {
		if let date = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultDateUserLeftAppId) as? NSDate
		{
			return date;
		}
		
		return NSDate();
	}
}