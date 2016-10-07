//
//  AccountDetailViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import TSMessages

enum AccountDetailSource {
    case SourceCalendar
    case SourceAccounts
}

class AccountDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var accountTypeLabel: UILabel!
    
    @IBOutlet weak var accountTypeViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bankImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var source: AccountDetailSource!
    
    private var userAccount = UserAccountEntity()
    
    var screenType: UIDeviceInfo.ScreenType?
    let kAccountTypeViewHeightiPhone4: CGFloat = 50
    let kBankImageViewHeightiPhone4: CGFloat = 100
    
    let kAccountDetailCellIdentifier = "accountDetailCellIdentifier"
    let kEditAccountSegue = "editAccountSegue"
    
    var savingsFromPayment: Double = 0
    var extraPayment: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenType = UIDeviceInfo.screenType()
        self.accountTypeLabel.text = self.userAccount.accountType
        
        self.imageView.contentMode = .ScaleAspectFit
        let bankImageService = GetBankLoginFormService(auth: ConfigFactory.getAuth())
        bankImageService.execute(self.userAccount.bankId) { (result) in
            if (result.bankLogo != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.imageView.sd_setImageWithURL(NSURL(string: result.bankLogo!), completed: { (image, error, cacheType, url) -> Void in
                    })
                })
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let accountResult = GetLoanAndCreditAccountsService().getAccounts()
            if accountResult.code != .Success {
                // No accounts found
                return
            }
            
            let calculationAlgorithm = NSUserDefaults.getCalculationAlgorithm()
            
            let minimumPaymentResult = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm)
            if (minimumPaymentResult.code == .NotFound || minimumPaymentResult.code == .Error) {
                return
            }
            
            let currentPaymentResult = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm, withTotalMonthlyPayment: NSUserDefaults.getTotalMonthlyMinimumPayment())
            if (currentPaymentResult.code == .Error) {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let differenceInInterestPaid = (minimumPaymentResult.interestPaid - currentPaymentResult.interestPaid)
                let differenceInPayment = NSUserDefaults.getTotalMonthlyMinimumPayment() - accountResult.totalMinimumPayments
                self.savingsFromPayment = Int.convertToCurrency(differenceInInterestPaid)
                self.extraPayment = Int.convertToCurrency(differenceInPayment)
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.screenType == .iPhone4) {
            self.accountTypeViewHeightConstraint.constant = kAccountTypeViewHeightiPhone4
            self.bankImageViewHeightConstraint.constant = kBankImageViewHeightiPhone4
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUserAccount(account: UserAccountEntity) {
        self.userAccount = account
    }
    
    func showBanner(message: String) {
        // Displays starting at the bottom of the nav bar, but overlaps
        TSMessage.setDefaultViewController(self.navigationController)
        // Without it, displays from the very top
        TSMessage.showNotificationWithTitle(message, type: TSMessageNotificationType.Success)
    }
    
    func hideBanner() {
        TSMessage.dismissActiveNotification()
    }
    
    func showAccountUpdatedBanner() {
        self.showBanner("Account was updated successfully")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideBanner()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == kEditAccountSegue) {
            let destination = segue.destinationViewController as! EditAccountViewController
            destination.source = self.source
            destination.userAccount = self.userAccount
            
        }
    }
}

extension AccountDetailViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountsData.sharedAccountsData.accountFields.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kAccountDetailCellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = AccountsData.sharedAccountsData.accountFields[indexPath.row]
        cell.detailTextLabel?.text = self.valueForRow(indexPath.row)
        cell.backgroundColor = (indexPath.row % 2 != 0) ? tableViewCellLighterBlue() : tableViewCellDarkerBlue()
        
        return cell
    }
    
    func valueForRow(row: NSInteger) -> String {
        var value = 0.0
        var valueString = ""
        switch (row) {
        case 0:
            value = userAccount.totalBalance
            valueString = String(format: "$%.02f", value)
            break
        case 1:
            value = userAccount.minimumPayment
            valueString = String(format: "$%.02f", value)
            break
        case 2:
            // payment due date
            valueString = self.stringForDate()
            break
        case 3:
            value = userAccount.APRPercentage
            valueString = String(format: "%.02f%%", value)
            break
        case 4:
            // extra payment planned
            value = self.extraPayment
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .CurrencyStyle
            valueString = numberFormatter.stringFromNumber(value)!
            break
        case 5:
            // savings from extra payment
            value = self.savingsFromPayment
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .CurrencyStyle
            valueString = numberFormatter.stringFromNumber(value)!
            break
        case 6:
            // last data refresh date
            if let refreshDate = userAccount.lastDataRefreshDate {
                let dateFmt = NSDateFormatter()
                dateFmt.dateFormat = "MM/dd/yyyy HH:mm"
                value = NSDate.timeIntervalSinceReferenceDate()
                valueString = dateFmt.stringFromDate(refreshDate)
            }
            break
        default:
            break
        }
        
        return valueString
    }
    
    func stringForDate() -> String {
        var string = ""
        if (userAccount.dayOfMonthWhenDue != 0) {
            
            let day = userAccount.dayOfMonthWhenDue
            let today = NSDate()
            
            let todayComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: today)
            var month = todayComponents.month - 1 // 0 index for the month titles
            // If this day has already passed this month
            if (day < todayComponents.day) {
                // advance to the enxt month
                month += 1
            }
            
            string = String(format: "%@ %i", AccountsData.sharedAccountsData.monthTitles[month], day)
        }
        return string
    }
}

