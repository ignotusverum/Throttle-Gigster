//
//  SnowballAvalancheCalculationService.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift

enum CalculationAlgorithm: String {
    case HighestAprFirst = "snowballHighestApr"
    case LowestBalanceFirst = "snowballLowestBalance"
}

class SnowballAvalancheCalculationService: BaseService {
    class CalculationAccounts {
        var minimumPayment: Int
        var currentBalance: Int
        var interestRate: Double
        var accountName: String
        
        init(minPayment: Int, currentBalance: Int, interestRate: Double, accountName: String) {
            self.minimumPayment = minPayment
            self.currentBalance = currentBalance
            self.interestRate = interestRate
            self.accountName = accountName
        }
    }
    
    let logDetails: Bool
    init(logDetails: Bool) {
        self.logDetails = logDetails
    }
    
    func executeWithSnowballAlgorithm(algorithm: CalculationAlgorithm, withTotalMonthlyPayment userMonthlyPayment: Int? = nil) -> SnowballAvalancheCalculationResult {
        /*
         let todaysDate = NSDate()
         let components = NSCalendar.currentCalendar().components([.Month, .Year, .Day], fromDate: todaysDate)
         let startingMonth = components.month
         let startingYear = components.year
         */
        
        // TODO: Testing
        let startingMonth = 1
        let startingYear = 2015
        // TODO: End testing
        
        var currentMonth = startingMonth
        var currentYear = startingYear
        
        
        
        var calcAccounts: [CalculationAccounts]?
        
        let sortColumn: AccountSortColumn
        let sortAscending: Bool
        switch algorithm {
        case .HighestAprFirst:
            sortColumn = .APR
            sortAscending = false
        case .LowestBalanceFirst:
            sortColumn = .RemainingBalance
            sortAscending = true
        }
        
        let accountsResult = GetLoanAndCreditAccountsService().getAccountsSortedByColumn(sortColumn, ascending: sortAscending)
        
        if (accountsResult.code == .Success) {
            calcAccounts = self.convertRealmAccounts(accountsResult.accounts)
        } else {
            let result = SnowballAvalancheCalculationResult()
            result.code = .Error
            result.message = "Error opening database"
            return result
        }
        
        guard let accounts = calcAccounts else {
            let result = SnowballAvalancheCalculationResult()
            result.code = .Error
            result.message = "Error opening database"
            return result
        }
        
        if (accounts.count == 0) {
            let result = SnowballAvalancheCalculationResult()
            result.code = .NotFound
            result.message = "No accounts found"
            return result
        }
        
        let monthlyPayment: Int
        if let userMonthlyPayment = userMonthlyPayment {
            if userMonthlyPayment < accountsResult.totalMinimumPayments {
                let result = SnowballAvalancheCalculationResult()
                result.code = .Error
                result.message = "Specified payment amount is less than the total minimum payment for your accounts. Please increase your monthly payment."
                return result
            } else {
                monthlyPayment = userMonthlyPayment
            }
        } else {
            monthlyPayment = accountsResult.totalMinimumPayments
        }
        
        if !minimumPaymentExceedsInterest(monthlyPayment, accounts: accounts) {
            let result = SnowballAvalancheCalculationResult()
            result.code = .Error
            result.message = "Specified monthly payment is less than total monthly interest accrued. Please increase your monthly payment."
            return result
        }
        
        log("Monthly payment: \(Int.convertToCurrency(monthlyPayment))")
        
        let initialSnowball = monthlyPayment - accountsResult.totalMinimumPayments
        
        log("Initial snow ball \(Int.convertToCurrency(initialSnowball))\n\n")
        
        var totalInterestPaid = 0
        var totalMonthsSpent = 0
        while (anAccountBalancesAreGreaterThanZero(accounts)) {
            var monthSnowball = initialSnowball
            
            for account in accounts {
                if (account.currentBalance <= 0) {
                    monthSnowball += account.minimumPayment; // gather the accounts that no longer need payments and add them to the snowball amount
                }
            }
            
            log("Monthly Snow Ball: $\(Int.convertToCurrency(monthSnowball)) for month: \(currentMonth)-\(currentYear)")
            
            for account in accounts {
                if (account.currentBalance <= 0) {
                    continue
                }
                
                log("Account name: \(account.accountName)")
                
                let accountCurrentBalance = account.currentBalance
                let accountInterestRate = account.interestRate
                
                let yearlyInterestRateDollarAmount = Int.percentageOfMoneyToCents(accountCurrentBalance, percent: accountInterestRate)
                
                log("Account current balance: \(Int.convertToCurrency(accountCurrentBalance))")
                log("Account interest rate: \(accountInterestRate)")
                log("Account interest rate in dollars (year): \(yearlyInterestRateDollarAmount)")
                
                let preciseMonthlyInterest = Double(yearlyInterestRateDollarAmount) / 12.0
                log("Account interest rate in dollars (month, accurate): \(round(preciseMonthlyInterest))")
                
                let monthlyInterestRateDollarAmount = Int(round(preciseMonthlyInterest))
                log("Account interest rate in dollars (month): \(Int.convertToCurrency(monthlyInterestRateDollarAmount))")
                
                let balanceAfterInterest = accountCurrentBalance + monthlyInterestRateDollarAmount
                log("Account balance after interest is applied: \(Int.convertToCurrency(balanceAfterInterest))")
                
                let minimumPayment = account.minimumPayment
                log("Account minimum payment: \(Int.convertToCurrency(minimumPayment))")
                
                let maximumPayment = minimumPayment + monthSnowball
                monthSnowball = 0
                log("Maximum payment after adding snowball: \(Int.convertToCurrency(maximumPayment))")
                
                if maximumPayment >= balanceAfterInterest {
                    account.currentBalance = 0
                    monthSnowball = maximumPayment - balanceAfterInterest
                    
                    log(" -- Account is fully paid off.")
                    log(" -- Remaining snowball: \(Int.convertToCurrency(monthSnowball))")
                } else {
                    account.currentBalance = balanceAfterInterest - maximumPayment
                    log("Account balance after payment: \(Int.convertToCurrency(account.currentBalance))")
                }
                
                totalInterestPaid += monthlyInterestRateDollarAmount
                
                log("\n\n")
            }
            
            if monthSnowball > 0 {
                // update monthly snowballs
                for account in accounts {
                    if (account.currentBalance > 0) {
                        let newBalance = account.currentBalance - monthSnowball
                        if (newBalance >= 0) {
                            account.currentBalance = newBalance
                            monthSnowball = 0
                            break
                        } else {
                            monthSnowball -= account.currentBalance
                            account.currentBalance = 0
                        }
                    }
                }
            }
            
            currentMonth += 1
            if (currentMonth > 12) {
                currentYear += 1
                currentMonth = 1
            }
            
            totalMonthsSpent += 1
            log("\n\n=============== Month \(totalMonthsSpent) over =================\n\n\n\n")
        }
        
        let result = SnowballAvalancheCalculationResult()
        
        log("\n\n=========DONE=========\n\n")
        log("Starting month: \(startingMonth)")
        log("Starting year: \(startingYear)\n")
        log("Ending month: \(currentMonth)")
        log("Ending year: \(currentYear)\n")
        
        result.numberOfMonthsToPayOff = totalMonthsSpent
        result.interestPaid = totalInterestPaid
        return result
    }
    
    private func convertRealmAccounts(accounts: [UserAccountEntity]) -> [CalculationAccounts] {
        var calcAccounts: [CalculationAccounts] = []
        
        for account in accounts {
            let interestRate = account.APRPercentage / 100
            calcAccounts.append(CalculationAccounts(minPayment: Int.convertToCents(account.minimumPayment), currentBalance: Int.convertToCents(account.totalBalance), interestRate: interestRate, accountName: account.accountName))
        }
        
        return calcAccounts
    }
    
    private func anAccountBalancesAreGreaterThanZero(accounts: [CalculationAccounts]) -> Bool {
        var atLeastOneAccountGreaterThanZero = false
        for account in accounts {
            if account.currentBalance > 0 {
                atLeastOneAccountGreaterThanZero = true
                break
            }
            
        }
        
        return atLeastOneAccountGreaterThanZero
    }
    
    private func minimumPaymentExceedsInterest(minimumPayment: Int, accounts: [CalculationAccounts]) -> Bool {
        var totalMonthlyInterest = 0.0
        for account in accounts {
            let yearlyInterestRateDollarAmount = Int.percentageOfMoneyToCents(account.currentBalance, percent: account.interestRate)
            let preciseMonthlyInterest = Double(yearlyInterestRateDollarAmount) / 12.0
            totalMonthlyInterest += preciseMonthlyInterest
        }
        
        if Double(minimumPayment) <= Double(totalMonthlyInterest) {
            return false
        }
        
        return true
    }
    
    func fetchAndGetTotalMinimumPaymentOfAccounts() -> Int {
        let accountResult = GetLoanAndCreditAccountsService().getAccounts()
        
        if accountResult.code == .Success {
            return accountResult.totalMinimumPayments
        } else {
            return 0
        }
    }
    
    private func log(logStr: String) {
        if (logDetails) {
            print(logStr)
        }
    }
}

