//
//  RefreshAccountDataResult.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class RefreshAllAccountDataResult: BaseResult {
	var loans : [RefreshAllAccountDataResultItems] = [];
	var credits : [RefreshAllAccountDataResultItems] = [];
	var banks : [RefreshAllAccountDataResultItems] = [];
}

enum RefreshAllAccountDataResultItemType : String {
	case Loans = "Loans"
	case Credit = "Credit"
	case Bank = "Bank"
}

class RefreshAllAccountDataResultItems {
	let accountName : String;
	let itemId : Int;
	let accountType : RefreshAllAccountDataResultItemType;
	var balance : Double = 0;
	var interestRate : Double = 0;
	var minimumAmountDue : Double = 0;
	var bankId = 0;
	var dayOfWeekDue : String?;
	var manualAccount = false;
	var containerType : String?;
  var lastDataRefreshDate: NSDate?
  var hasAPR = false;
  var hasPaymentDueDate = false;
	
	init(accountName: String, itemId: Int, accountType : RefreshAllAccountDataResultItemType) {
		self.accountName = accountName;
		self.itemId = itemId;
		self.accountType = accountType;
	}
}