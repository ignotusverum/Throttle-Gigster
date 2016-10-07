//
//  BankAccount.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/14/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift

class UserAccountEntity: Object {
  dynamic var accountId = 0;
  dynamic var userName = "";
  dynamic var accountName = "";
  dynamic var accountType = "";
  dynamic var APRPercentage = 0.0;
  dynamic var minimumPayment = 0.0;
  dynamic var totalBalance = 0.0;
  dynamic var dayOfMonthWhenDue = 0;
  dynamic var monthWhenDue = 0;
  dynamic var createdAt : NSDate?;
	dynamic var bankId = 0;
  dynamic var createdManually = false;
  dynamic var lastDataRefreshDate: NSDate?
  dynamic var hasAPR = false;
  dynamic var hasPaymentDueDate = false;
  
  override class func primaryKey() -> String? {
    return "accountId";
  }
  
  func toDictionary() -> NSMutableDictionary {
    let dictionary = NSMutableDictionary()
    dictionary[AccountKey.ID.rawValue] = self.accountId
    dictionary[AccountKey.UserName.rawValue] = self.userName
    dictionary[AccountKey.AccountType.rawValue] = self.accountType
    dictionary[AccountKey.InterestRate.rawValue] = self.APRPercentage
    dictionary[AccountKey.MinimumPayment.rawValue] = self.minimumPayment;
    dictionary[AccountKey.PrincipalBalance.rawValue] = self.totalBalance
    dictionary[AccountKey.PaymentDueDateMonth.rawValue] = self.monthWhenDue
    dictionary[AccountKey.PaymentDueDateDay.rawValue] = self.dayOfMonthWhenDue
    dictionary[AccountKey.CreatedAtDate.rawValue] = self.createdAt
    dictionary[AccountKey.CreatedManually.rawValue] = self.createdManually
    dictionary[AccountKey.LastDataRefreshDate.rawValue] = self.lastDataRefreshDate
    dictionary[AccountKey.HasAPR.rawValue] = self.hasAPR
    dictionary[AccountKey.HasPaymentDueDate.rawValue] = self.hasPaymentDueDate
    
    return dictionary
  }
  
  func updateWithDictionary(dictionary:NSDictionary) {
    do {
      let realm = try Realm.getEncryptedInstance();
      realm.beginWrite()
      self.userName = dictionary[AccountKey.UserName.rawValue] as! String
      self.accountType = dictionary[AccountKey.AccountType.rawValue] as! String
      self.APRPercentage = dictionary[AccountKey.InterestRate.rawValue] as! Double
      self.minimumPayment = dictionary[AccountKey.MinimumPayment.rawValue] as! Double
      self.totalBalance = dictionary[AccountKey.PrincipalBalance.rawValue] as! Double
      self.monthWhenDue = dictionary[AccountKey.PaymentDueDateMonth.rawValue] as! Int
      self.dayOfMonthWhenDue = dictionary[AccountKey.PaymentDueDateDay.rawValue] as! Int
      self.createdAt = dictionary[AccountKey.CreatedAtDate.rawValue] as? NSDate
      self.createdManually = dictionary[AccountKey.CreatedManually.rawValue] as! Bool
      self.lastDataRefreshDate = dictionary[AccountKey.LastDataRefreshDate.rawValue] as? NSDate
      self.hasAPR = dictionary[AccountKey.HasAPR.rawValue] as! Bool
      self.hasPaymentDueDate = dictionary[AccountKey.HasPaymentDueDate.rawValue] as! Bool
      
      try realm.commitWrite()
    } catch {
      print(error)
    }
  }
  
//  func deleteAccount() {
//    
//    do {
//      let realm = try Realm.getEncryptedInstance();
//      realm.beginWrite()
//      realm.delete(self)
//      
//      try realm.commitWrite()
//    } catch {
//      print(error)
//    }
//  }
}
