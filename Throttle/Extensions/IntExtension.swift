//
//  IntExtension.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/14/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

extension Int {
	var ordinal: String {
		get {
			var suffix: String = ""
			var ones: Int = self % 10;
			var tens: Int = (self/10) % 10;
			
			if (tens == 1) {
				suffix = "th";
			} else if (ones == 1){
				suffix = "st";
			} else if (ones == 2){
				suffix = "nd";
			} else if (ones == 3){
				suffix = "rd";
			} else {
				suffix = "th";
			}
			
			return suffix
		}
	}
	
	static func convertToCents(value: Double) -> Int {
		return Int(value * 100);
	}
	
	static func convertToCurrency(value: Int) -> Double {
		return Double(value) / 100.0;
	}
	
	static func percentageOfMoneyToCents(currency: Int, percent: Double) -> Int {
		let preciseCalc = Double(currency) * percent;
		return Int(preciseCalc);
	}
}
