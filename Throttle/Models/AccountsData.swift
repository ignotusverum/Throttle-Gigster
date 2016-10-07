//
//  AccountsData.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
enum AccountKey: String {
  case PrincipalBalance = "kPrincipalBalance"
  case MinimumPayment = "kMinimumPayment"
  case PaymentDueDate = "kPaymentDueDate"
  case PaymentDueDateMonth = "kPaymentDueDateMonth"
  case PaymentDueDateDay = "kPaymentDueDateDay"
  case InterestRate = "kInterestRate"
  case ExtraPaymentPlanned = "kExtraPaymentPlanned"
  case SavingsFromExtraPayment = "kSavingsFromExtraPayment"
  case LastDataRefreshDate = "kLastDataRefreshDate"
   case LastDataRefreshDateMonth = "kLastDataRefreshDateMonth"
   case LastDataRefreshDateDay = "kLastDataRefreshDateDay"
  case ID = "kAccountID"
  case UserName = "kUserName"
  case Name = "kAccountName"
  case AccountType = "kAccountType"
  case CreatedAtDate = "kCreatedAtDate"
  case CreatedManually = "kCreatedManually"
  case HasAPR = "kHasAPR"
  case HasPaymentDueDate = "kHasPaymentDueDate"
  
}

class AccountsData: NSObject {
  static let sharedAccountsData = AccountsData()
  
  let accountKeysForTable: [AccountKey] = [.PrincipalBalance, .MinimumPayment, .PaymentDueDate, .InterestRate, .ExtraPaymentPlanned, .SavingsFromExtraPayment, .LastDataRefreshDate]
  
  let accountFields : [String] = ["Principal Balance", "Minimum Payment", "Payment Due Date", "Interest Rate", "Extra Payment Planned", "Savings from Extra Payment", "Last Data Refresh Date"];
  
  let months : [String] = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
  let monthTitles : [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}
