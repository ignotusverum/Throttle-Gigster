
//
//  SaveRefreshDataService.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class SaveRefreshDataService: BaseService {
	var realmItems: [UserAccountEntity] = [];
	
	func saveRefreshResult(result: RefreshAllAccountDataResult) {
		for item in result.banks {
			self.saveItem(item);
		}
		
		for item in result.credits {
			self.saveItem(item);
		}
		
		for item in result.loans {
			self.saveItem(item);
		}
		
		
		do {
			let realm = try Realm.getEncryptedInstance();
			
			for account in self.realmItems {
				try realm.write {
					realm.add(account, update: true);
				}
			}
		}
		catch {
			CLSLogv("Realm Error: %@", getVaList(["\(error)"]));
			Crashlytics.sharedInstance().throwException();
		}
	}
	
	func saveItem(item: RefreshAllAccountDataResultItems) {
		let newAccount = UserAccountEntity();

		newAccount.accountId = item.itemId;
		newAccount.accountName = item.accountName;
		newAccount.accountType = item.accountType.rawValue;
		newAccount.APRPercentage = item.interestRate;
		newAccount.minimumPayment = item.minimumAmountDue;
		newAccount.totalBalance = item.balance;
		newAccount.createdManually = item.manualAccount;
		newAccount.bankId = item.bankId;
    newAccount.lastDataRefreshDate = item.lastDataRefreshDate;
    newAccount.hasAPR = item.hasAPR;
    newAccount.hasPaymentDueDate = item.hasPaymentDueDate;
		
		if let dayDue = item.dayOfWeekDue {
			let dayInt = (dayDue as NSString).integerValue;
			newAccount.dayOfMonthWhenDue = dayInt;
		}
		
		self.realmItems.append(newAccount);
	}
}
