//
// EditAccountViewController.swift
// Throttle
//
// Created by Kaitlyn Lee on 3/6/16.
// Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class EditAccountViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bankImageView: UIImageView!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var bankImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountTypeViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveButtonHeightConstraint: NSLayoutConstraint!
    
    var source: AccountDetailSource!
    var hasUnsavedEdits: Bool!
    var screenType: UIDeviceInfo.ScreenType?
    let kEditAccountCellIdentifier = "editAccountCellIdentifier"
    let kAccountTypeViewHeightiPhone4: CGFloat = 50
    let kBankImageViewHeightiPhone4: CGFloat = 100
    let kSaveButtonTopBottomPaddingiPhone4: CGFloat = 10
    
    var userAccount = UserAccountEntity()
    var userAccountDictionary: NSMutableDictionary!
    
    var savingsFromPayment: Double = 0
    var extraPayment: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backAlert))
        self.navigationItem.leftBarButtonItem = backButton
        self.hasUnsavedEdits = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.screenType = UIDeviceInfo.screenType()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(detailChangedValue(_:)), name: "DetailChangedValueNotification", object: nil)
        self.userAccountDictionary = self.userAccount.toDictionary()
        
        let bankImageService = GetBankLoginFormService(auth: ConfigFactory.getAuth())
        bankImageService.execute(self.userAccount.bankId) { (result) in
            if (result.bankLogo != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.bankImageView.sd_setImageWithURL(NSURL(string: result.bankLogo!), completed: { (image, error, cacheType, url) -> Void in
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
    
    func detailChangedValue(notification: NSNotification) {
        print(notification.userInfo)
        let key = notification.userInfo!["key"] as! String
        
        if (key == AccountKey.PaymentDueDate.rawValue || key == AccountKey.LastDataRefreshDate.rawValue) {
            // Has a second object
            let month = notification.userInfo!["value1"] as! Int
            let day = notification.userInfo!["value2"] as! Int
            self.saveDateToDictionary(key, month: month, day: day)
        } else {
            let value = notification.userInfo!["value1"] as! Double
            self.saveValueToDictionary(key, value: value)
        }
    }
    
    func saveValueToDictionary(key: String, value: Double) {
        print(self.userAccountDictionary)
//      self.userAccount.setValue(value, forKey: key)
        self.userAccountDictionary[key] = value
        self.writeOutDictionary()
    }
    
    func saveDateToDictionary(key: String, month: Int, day: Int) {
        let monthKey = key + "Month"
        let dayKey = key + "Day"
        
        self.userAccountDictionary[monthKey] = month
        self.userAccountDictionary[dayKey] = day
        self.writeOutDictionary()
    }
    
    func writeOutDictionary() {
        print(self.userAccountDictionary)
        self.userAccount.updateWithDictionary(self.userAccountDictionary)
        self.hasUnsavedEdits = false
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.screenType == .iPhone4) {
            self.accountTypeViewHeightConstraint.constant = kAccountTypeViewHeightiPhone4
            self.bankImageViewHeightConstraint.constant = kBankImageViewHeightiPhone4
            self.saveButtonTopConstraint.constant = kSaveButtonTopBottomPaddingiPhone4
            self.saveButtonBottomConstraint.constant = kSaveButtonTopBottomPaddingiPhone4
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enteredText(sender: AnyObject) {
        self.hasUnsavedEdits = true
    }
    
    @IBAction func pressedSave(sender: AnyObject) {
        self.saveInfo()
    }
    
    func saveInfo() {
        print("Save here")
        self.hasUnsavedEdits = false
        // need to get a dictionary of items
        self.writeOutDictionary()
        
        let auth = ConfigFactory.getAuth()
        let updateAccountService = UpdateAccountService(auth: auth, account: self.userAccount)
        updateAccountService.execute { (success) in
            print("Updated")
            if (success == true) {
                let notificationService = NotificationsService(auth: ConfigFactory.getAuth())
                notificationService.clearAndRegisterAllNotifications()
                
                for controller: UIViewController in (self.navigationController?.viewControllers)! as [UIViewController] {
                    if controller.isKindOfClass(AccountDetailViewController) {
                        let debtDetail = controller as! AccountDetailViewController
                        debtDetail.showAccountUpdatedBanner()
                        break
                    }
                }
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                let alertController = UIAlertController(title: "Error", message: "Error updating account", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    }))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tap() {
        print("Tap")
        self.view.endEditing(true)
    }
    
    @IBAction func trashButtonPressed(sender: AnyObject) {
        let notSavedVC = DeleteAccountViewController()
        notSavedVC.userAccount = self.userAccount
        notSavedVC.completionHandler = { (shouldDelete: Bool) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            if (shouldDelete == true) {
                print("Delete")
                
                let notificationService = NotificationsService(auth: ConfigFactory.getAuth())
                notificationService.clearAndRegisterAllNotifications()
                
                for controller: UIViewController in (self.navigationController?.viewControllers)! as [UIViewController] {
                    if (self.source == AccountDetailSource.SourceAccounts) {
                        if (controller.isKindOfClass(AccountsViewController)) {
                            let accountsViewController = controller as! AccountsViewController
                            accountsViewController.showAccountDeletedBanner()
                            self.navigationController?.popToViewController(accountsViewController, animated: true)
                            break
                        }
                    }
                    if (self.source == AccountDetailSource.SourceCalendar) {
                        if (controller.isKindOfClass(CalendarViewController)) {
                            let calendarViewController = controller as! CalendarViewController
                            calendarViewController.showAccountDeletedBanner()
                            self.navigationController?.popToViewController(calendarViewController, animated: true)
                            break
                        }
                        
                    }
                }
            }
        }
        notSavedVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(notSavedVC, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func backAlert() {
        print("Back button pressed")
        if (self.hasUnsavedEdits == true || self.isEditingText()) {
            
            let notSavedVC = EditsNotSavedViewController()
            notSavedVC.completionHandler = { (shouldSave: Bool) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                if (shouldSave == true) {
                    print("Save")
                    self.saveInfo()
                    for controller: UIViewController in (self.navigationController?.viewControllers)! as [UIViewController] {
                        if controller.isKindOfClass(AccountDetailViewController) {
                            let debtDetail = controller as! AccountDetailViewController
                            debtDetail.showAccountUpdatedBanner()
                            break
                        }
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    print("BACK")
                }
            }
            notSavedVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(notSavedVC, animated: true, completion: nil)
            
        } else {
//        self.saveInfo()
            for controller: UIViewController in (self.navigationController?.viewControllers)! as [UIViewController] {
                
                if controller.isKindOfClass(AccountDetailViewController) {
                    let accountDetail = controller as! AccountDetailViewController
                    accountDetail.showAccountUpdatedBanner()
                    break
                }
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func isEditingText() -> Bool {
        let activeView = self.findActiveResponderFrame(self.tableView)
        if ((activeView != nil) && (activeView?.isKindOfClass(UITextField) == true)) {
            return true
        }
        return false
    }
    
    func findActiveResponderFrame(view: UIView) -> UIView? {
        if view.isFirstResponder() {
            return view
        } else {
            for subView in view.subviews {
                if let foundView = findActiveResponderFrame(subView) {
                    return foundView
                }
            }
        }
        return nil
    }
}

extension EditAccountViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountsData.sharedAccountsData.accountFields.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kEditAccountCellIdentifier, forIndexPath: indexPath) as! EditDebtTableViewCell
        
        cell.label.text = AccountsData.sharedAccountsData.accountFields[indexPath.row]
        
        let values = valuesToDisplay(indexPath.row)
        cell.setValuesAndDisplay(values.first, second: values.second, type: self.typeForRow(indexPath.row), accountKey: AccountsData.sharedAccountsData.accountKeysForTable[indexPath.row])
        
        if (userAccount.createdManually == false) {
            // Do not let the user to edit these fields if the account was added through yodlee
            if (indexPath.row == 0 ||
                indexPath.row == 1 ||
                (indexPath.row == 2 && userAccount.hasPaymentDueDate) || (indexPath.row == 3 && userAccount.hasAPR)) {
                    
                    cell.disableField()
            } else {
                    cell.enableField()
            }
        } else if (indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6) {
            cell.disableField()
        } else {
            cell.enableField()
        }
        
        return cell
    }
    
    func typeForRow(row: NSInteger) -> ValueType {
        if (row == 0 || row == 1 || row == 4 || row == 5) {
            return .Money
        } else if (row == 3) {
            return .Percent
        } else if (row == 2 || row == 6) {
            return .Date
        }
        return .None
    }
    
    func valuesToDisplay(row: NSInteger) -> (first: NSNumber, second: NSNumber) {
        switch (row) {
        case 0:
            return (userAccount.totalBalance, 0)
        case 1:
            return (userAccount.minimumPayment, 0)
        case 2:
            // payment due date
            return (self.monthForDate(userAccount.dayOfMonthWhenDue), userAccount.dayOfMonthWhenDue)
        case 3:
            return (userAccount.APRPercentage, 0)
        case 4:
            // extra payment planned
            return (self.extraPayment, 0)
        case 5:
            // savings from extra payment
            return (self.savingsFromPayment, 0)
        case 6:
            // last data refresh date
            if let refreshDate = userAccount.lastDataRefreshDate {
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components([.Day, .Month], fromDate: refreshDate)
                
                let month = components.month
                let day = components.day
                
                return (month, day)
            }
            break
        default:
            break
        }
        return (0, 0)
    }
    
    func monthForDate(day: Int) -> Int {
        let today = NSDate()
        
        let todayComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: today)
        var month = todayComponents.month - 1 // 0 index for the month titles
        // If this day has already passed this month
        if (day < todayComponents.day) {
            // advance to the enxt month
            month += 1
        }
        return month
    }
}
