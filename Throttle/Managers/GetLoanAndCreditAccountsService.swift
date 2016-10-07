//
//  GetLoanAndCreditAccountsService.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift

enum AccountSortColumn: String {
    case APR = "APRPercentage"
    case RemainingBalance = "totalBalance"
}

class GetLoanAndCreditAccountsService: BaseService {
    func getAccounts() -> GetLoansAndCreditAccountsResult {
        return getAccountsInternal(column: nil, ascending: nil)
    }
    
    func getAccountsSortedByColumn(column: AccountSortColumn, ascending: Bool) -> GetLoansAndCreditAccountsResult {
        return getAccountsInternal(column: column, ascending: ascending)
    }
    
    private func getAccountsInternal(column column: AccountSortColumn?, ascending: Bool?) -> GetLoansAndCreditAccountsResult {
        let serviceResult = GetLoansAndCreditAccountsResult()
        
        let accounts: [UserAccountEntity]
        do {
            let realm = try Realm.getEncryptedInstance()
            let realmAccounts = realm.objects(UserAccountEntity).filter("accountType = '\(RefreshAllAccountDataResultItemType.Credit.rawValue)' OR accountType = '\(RefreshAllAccountDataResultItemType.Loans.rawValue)'")
            
            if let column = column, ascending = ascending {
                accounts = Array(realmAccounts.sorted(column.rawValue, ascending: ascending))
            } else {
                accounts = Array(realmAccounts)
            }
        } catch {
            print(error)
            serviceResult.code = .Error
            
            return serviceResult
        }
        
        serviceResult.accounts = accounts
        var totalPrincipleBalance = 0
        var totalInterestOnPrincipleBalance = 0
        var totalPrinciplePlusInterestBalance = 0
        var totalMinimumPayments = 0
        
        // Cannot use doubles or floats when handling money, as this leads to floating-point math errors. Must perform all calculations as integers, representing cents.
        for accountEntity in accounts {
            totalPrincipleBalance += Int.convertToCents(accountEntity.totalBalance)
            
            let interest = accountEntity.APRPercentage
            let interestOnPrincipleBalance = Int.percentageOfMoneyToCents(Int.convertToCents(accountEntity.totalBalance), percent: interest)
            
            totalInterestOnPrincipleBalance += interestOnPrincipleBalance
            totalPrinciplePlusInterestBalance += Int.convertToCents(accountEntity.totalBalance) + interestOnPrincipleBalance
            
            totalMinimumPayments += Int.convertToCents(accountEntity.minimumPayment)
        }
        
        serviceResult.totalPrincipleBalance = totalPrincipleBalance
        serviceResult.totalInterestOnPrincipleBalance = totalInterestOnPrincipleBalance
        serviceResult.totalPrinciplePlusInterestBalance = totalPrinciplePlusInterestBalance
        serviceResult.totalMinimumPayments = totalMinimumPayments
        
        return serviceResult
    }
}
