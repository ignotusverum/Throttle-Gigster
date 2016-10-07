//
//  SavingsPlanViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/24/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift

class SavingsPlanViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var yearsSavedLabel: UILabel!
    @IBOutlet var monthsSavedLabel: UILabel!
    @IBOutlet var moneySavedLabel: UILabel!
    @IBOutlet var savingsPlanContainerView: UIView!
    
    var layedOutSubviews = false
    var scrollViewYOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.yearsSavedLabel.text = "0"
        self.monthsSavedLabel.text = "0"
        self.moneySavedLabel.text = "0"
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let accountResult = GetLoanAndCreditAccountsService().getAccounts()
            if accountResult.code == .Error {
                // Error retrieving accounts
                dispatch_async(dispatch_get_main_queue(), {
                    let vc = AlertUtil.getSimpleAlert("Error", message: "Error retrieving account data: \(accountResult.message ?? "\(accountResult.code.rawValue)")")
                    self.presentViewController(vc, animated: true, completion: nil)
                })
                return
            } else if accountResult.code == .NotFound {
                // No accounts found
                return
            }
            
            
            
            let calculationAlgorithm = NSUserDefaults.getCalculationAlgorithm()
            
            let minimumPaymentResult = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm)
            let currentPaymentResult = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm, withTotalMonthlyPayment: NSUserDefaults.getTotalMonthlyMinimumPayment())
            
            dispatch_async(dispatch_get_main_queue(), {
                if (currentPaymentResult.code == .Error) {
                    self.yearsSavedLabel.text = ""
                    self.monthsSavedLabel.text = ""
                    self.monthsSavedLabel.text = ""
                    
                    let vc = AlertUtil.getSimpleAlert("Error", message: "Error calculating final results: \(currentPaymentResult.message ?? "\(currentPaymentResult.code.rawValue)")" )
                    self.presentViewController(vc, animated: true, completion: nil)
                } else if (minimumPaymentResult.code == .Error) {
                    self.yearsSavedLabel.text = "N/A"
                    self.monthsSavedLabel.text = "N/A"
                    self.monthsSavedLabel.text = "N/A"
                } else {
                    let numberOfMonthsBetweenDates = minimumPaymentResult.numberOfMonthsToPayOff - currentPaymentResult.numberOfMonthsToPayOff
                    
                    let differenceInMonths = numberOfMonthsBetweenDates % 12
                    let differenceInYears = numberOfMonthsBetweenDates / 12
                    let differenceInInterestPaid = (minimumPaymentResult.interestPaid - currentPaymentResult.interestPaid)
                    
                    self.yearsSavedLabel.text = "\(differenceInYears)"
                    self.monthsSavedLabel.text = "\(differenceInMonths)"
                    
                    let numberFormatter = NSNumberFormatter()
                    numberFormatter.numberStyle = .CurrencyStyle
                    let moneySaved: Double = Int.convertToCurrency(differenceInInterestPaid)
                    self.moneySavedLabel.text = numberFormatter.stringFromNumber(moneySaved)
                }
            })
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!layedOutSubviews) {
            layedOutSubviews = true
            self.addCards()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollView.contentSize = CGSizeMake(100, self.scrollViewYOffset)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.presentSideBar.rawValue, object: nil)
    }
    
    func addCards() {
        // Sort the displayed accounts in current payment order
        let sortColumn: AccountSortColumn
        let sortAscending: Bool
        switch NSUserDefaults.getCalculationAlgorithm() {
        case .HighestAprFirst:
            sortColumn = .APR
            sortAscending = false
        case .LowestBalanceFirst:
            sortColumn = .RemainingBalance
            sortAscending = true
        }
        
        let accountResult = GetLoanAndCreditAccountsService().getAccountsSortedByColumn(sortColumn, ascending: sortAscending)
        let accounts = accountResult.accounts
        
        if accounts.isEmpty {
            let vc = AlertUtil.getSimpleAlert("Error", message: "No accounts found")
            self.presentViewController(vc, animated: true, completion: nil)
            return
        }
        
        var yOffset = self.savingsPlanContainerView.frame.size.height + 20
        
        let width = self.view.frame.size.width
        let horizontalMargin: CGFloat = 20
        let viewWidth = width - (horizontalMargin * 2)
        let heightOfEachView: CGFloat = 60
        
        let startingColorRed: CGFloat = 206 / 255.0
        let startingColorGreen: CGFloat = 35.0 / 255.0
        let startingColorBlue: CGFloat = 41.0 / 255.0
        
        let endingColorRed: CGFloat = 55.0 / 255.0
        let endingColorGreen: CGFloat = 169 / 255.0
        let endingColorBlue: CGFloat = 70.0 / 255.0
        
        // change the color red to 0 in X number of steps
        
        let numberOfSteps = accounts.count
        let subtractFromRed = (startingColorRed - endingColorRed) / CGFloat(numberOfSteps)
        let addFromGreen = (endingColorGreen - startingColorGreen) / CGFloat(numberOfSteps)
        let addFromBlue = (endingColorBlue - startingColorBlue) / CGFloat(numberOfSteps)
        
        var changeInRedColor = startingColorRed
        var changeInGreenColor = startingColorGreen
        var changeInBlueColor = startingColorBlue
        
        for account in accounts {
            let savingsPlanView = SavingsPlanAccountView.initFromNib()
            savingsPlanView.frame = CGRectMake(horizontalMargin, yOffset, viewWidth, heightOfEachView)
            savingsPlanView.backgroundColorShadeView.backgroundColor = UIColor(red: changeInRedColor, green: changeInGreenColor, blue: changeInBlueColor, alpha: 1)
            savingsPlanView.accountNameLabel.text = account.accountName
            savingsPlanView.userAccountEntity = account
            savingsPlanView.delegate = self
            
            if (account.createdManually) {
                savingsPlanView.callButton.hidden = true
            }
            
            self.scrollView.addSubview(savingsPlanView)
            yOffset += heightOfEachView
            
            changeInRedColor -= subtractFromRed
            changeInGreenColor += addFromGreen
            changeInBlueColor += addFromBlue
        }
        
        yOffset += 20
        
        self.scrollViewYOffset = yOffset
        self.scrollView.contentSize = CGSizeMake(self.savingsPlanContainerView.frame.size.width, yOffset)
    }
    
}

extension SavingsPlanViewController: SavingsPlanAccountViewDelegate {
    func didTapOnSavingsPlan(entity: UserAccountEntity) {
        let alert = AlertUtil.getSimpleAlert("Call", message: "Phone numbers are not provided by Yodlee at this time")
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
