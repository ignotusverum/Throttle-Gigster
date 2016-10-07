//
//  AccountsViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/4/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import TSMessages
import RealmSwift

class AccountsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var interestYouOweLabel: UILabel!
    @IBOutlet weak var savingsFromPlanLabel: UILabel!
    
    let kAccountsCellIdentifier = "accountsCellIdentifier"
    let kAccountDetailSegue = "accountDetailSegue"
    
    var accounts = [UserAccountEntity]()
    var indexSelected: NSInteger = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(addAccount))
        self.navigationItem.rightBarButtonItem = addButton
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let accountResult = GetLoanAndCreditAccountsService().getAccounts()
            if accountResult.code != .Success {
                // No accounts found
                return
            }
            
            let calculationAlgorithm = NSUserDefaults.getCalculationAlgorithm()
            
            let minimumPaymentResult = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm)
            if (minimumPaymentResult.code == .Error) {
                return
            }
            
            let currentPaymentResult = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm, withTotalMonthlyPayment: NSUserDefaults.getTotalMonthlyMinimumPayment())
            if (currentPaymentResult.code == .Error) {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let differenceInInterestPaid = (minimumPaymentResult.interestPaid - currentPaymentResult.interestPaid)
                
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .CurrencyStyle
                let moneySaved: Double = Int.convertToCurrency(differenceInInterestPaid)
                self.savingsFromPlanLabel.text = numberFormatter.stringFromNumber(moneySaved)
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            let realm = try Realm.getEncryptedInstance()
            let realmAccounts = realm.objects(UserAccountEntity)
            accounts = Array(realmAccounts)
            
            print(accounts.count, "accounts")
            print(accounts)
        }
        catch {
            print(error)
            accounts = [UserAccountEntity]()
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAccount() {
        // bankSearchVC
        let bankSearchVC = StoryboardUtil.getBankSearchVC()
        self.navigationController!.pushViewController(bankSearchVC, animated: true)
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.presentSideBar.rawValue, object: nil)
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideBanner()
    }
    
    func showAccountDeletedBanner() {
        self.showBanner("Account was deleted successfully")
        do {
            
            let realm = try Realm.getEncryptedInstance()
            let realmAccounts = realm.objects(UserAccountEntity)
            accounts = Array(realmAccounts)
            
            print(accounts.count, "accounts")
            print(accounts)
        }
        catch {
            print(error)
            accounts = [UserAccountEntity]()
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == kAccountDetailSegue && self.indexSelected != -1) {
            let destination = segue.destinationViewController as! AccountDetailViewController
            print("Selected", indexSelected)
            destination.setUserAccount(self.accounts[indexSelected])
            destination.source = .SourceAccounts
        }
    }
}

extension AccountsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kAccountsCellIdentifier, forIndexPath: indexPath) as? DebtsTableViewCell
        
        cell!.backgroundColor = (indexPath.row % 2 != 0) ? tableViewCellDarkerBlue() : tableViewCellLighterBlue()
        let balanceString = String(format: "$%.2f", self.accounts[indexPath.row].totalBalance)
        cell!.balanceLabel.text = balanceString
        let dayOfMonth = self.accounts[indexPath.row].dayOfMonthWhenDue
        if (dayOfMonth > 0) {
            cell!.dayLabel.text = String(dayOfMonth)
            cell!.monthLabel.text = AccountsData.sharedAccountsData.months[self.monthForDate(dayOfMonth)]
        } else {
            cell!.dayLabel.text = ""
            cell!.monthLabel.text = ""
        }
        cell!.accountCardLabel.text = self.accounts[indexPath.row].accountName
        return cell!
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

extension AccountsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexSelected = indexPath.row
        self.performSegueWithIdentifier(kAccountDetailSegue, sender: nil)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}