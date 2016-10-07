//
//  GetLoansAndCreditAccountsResult.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class GetLoansAndCreditAccountsResult: BaseResult {
	var accounts : [UserAccountEntity] = [];
	var totalPrincipleBalance : Int = 0;
	var totalInterestOnPrincipleBalance : Int = 0;
	var totalPrinciplePlusInterestBalance : Int = 0;
	var totalMinimumPayments : Int = 0;
	
	lazy var formatter : NSNumberFormatter = {
		let format = NSNumberFormatter();
		format.numberStyle = .CurrencyStyle;
		return format;
	}();
}
