//
//  ManualLoanInfo.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class ManualLoanInfo: NSObject {
	var accountName : String?;
	var loanType : String?;
	var aprPercentage : String?;
	var minimumPayment : String?
	var balance : String?;
	var paymentDueEachMonthInt : Int?;
	var paymentDueEachMonth : String?;
	
	
	var aprPercentageDouble :Double = 0;
	var minimumPaymentDouble :Double = 0;
	var balanceDouble :Double = 0;
}