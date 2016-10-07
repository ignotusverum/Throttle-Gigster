//
//  ConfirmAccountViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2016-01-02.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD;
import Crashlytics;

class ConfirmAccountViewController: UIViewController {
	let confirmAccountCellIdentifier = "confirmAccountCellIdentifier";
	let accountNameLabel = "Account name";
	let accountTypeLabel = "Account type";
	let aprPercentLabel = "APR %";
	let minimumPaymentLabel = "Minimum payment";
	let currentBalanceLabel = "Current balance";
	let paymentDateLabel = "Payment date";
	
	var tableDataSource : [[String: String]!]!;
	var manualLoanInfoModel : ManualLoanInfo!;
	
	@IBOutlet var tableView: UITableView!

	//MARK: - VC Lifecycle
    override func viewDidLoad() {
		super.viewDidLoad();
		
		self.title = "Confirming account information";
		self.tableDataSource = [
			[accountNameLabel : self.manualLoanInfoModel.accountName!],
			[accountTypeLabel : self.manualLoanInfoModel.loanType!],
			[aprPercentLabel : self.manualLoanInfoModel.aprPercentage!],
			[minimumPaymentLabel : self.manualLoanInfoModel.minimumPayment!],
			[currentBalanceLabel : self.manualLoanInfoModel.balance!],
			[paymentDateLabel : self.manualLoanInfoModel.paymentDueEachMonth!],
		];
		
		self.tableView.dataSource = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.blueBarColor();
		navigationController!.navigationBar.tintColor = Theme.blueBarTextColor();
		navigationController!.setNavigationBarHidden(false, animated: true)
	}

	//MARK: - Button events
	@IBAction func saveButtonTapped(sender: AnyObject) {
		MBProgressHUD.showHUDAddedTo((self.parentViewController?.view)!, animated: true);
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
			
			let addNewManualAccountService = AddManualBankService(auth: ConfigFactory.getAuth(), accountsData: self.manualLoanInfoModel);
			addNewManualAccountService.execute({ (result) in
        
				let refreshService = RefreshAllAccountDataService(auth: ConfigFactory.getAuth());
				refreshService.execute({ (result) in
					let saveDataService = SaveRefreshDataService();
					saveDataService.saveRefreshResult(result);
					
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						MBProgressHUD.hideAllHUDsForView((self.parentViewController?.view)!, animated: true);
						self.navigationController?.popToRootViewControllerAnimated(true)
					});
				});
			
			});
			
//			let dbBankAccount = UserAccountEntity();
//			dbBankAccount.accountName = self.manualLoanInfoModel.accountName!;
//			dbBankAccount.accountType = self.manualLoanInfoModel.loanType!;
//			
//			dbBankAccount.APRPercentage = self.manualLoanInfoModel.aprPercentageDouble;
//			dbBankAccount.minimumPayment = self.manualLoanInfoModel.minimumPaymentDouble;
//			dbBankAccount.totalBalance = self.manualLoanInfoModel.balanceDouble;
//			
//			dbBankAccount.dayOfMonthWhenDue = self.manualLoanInfoModel.paymentDueEachMonthInt!;
//			dbBankAccount.monthWhenDue = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate());
//			dbBankAccount.createdManually = true;
			
//			do {
//				let realm = try Realm.getEncryptedInstance();
//				try realm.write {
//					realm.add(dbBankAccount);
//				}
//			}
//			catch {
//				CLSLogv("Realm Error: %@", getVaList(["\(error)"]));
//				Crashlytics.sharedInstance().throwException();
//			}
//			
//			
			
		};
	}
	
	@IBAction func editButtonTapped(sender: AnyObject) {
		self.navigationController?.popViewControllerAnimated(true);
	}
	
}

//MARK: - UITableViewDataSource
extension ConfirmAccountViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tableDataSource.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(confirmAccountCellIdentifier, forIndexPath: indexPath);
		cell.selectedBackgroundView = UIView();
		cell.backgroundColor = (indexPath.row % 2 != 0) ? Theme.getConfirmAccountTableBackgroundColor1() : Theme.getConfirmAccountTableBackgroundColor2();
		
		let data = self.tableDataSource[indexPath.row];
		let leftLabel = cell.viewWithTag(5) as! UILabel;
		let rightLabel = cell.viewWithTag(10) as! UILabel;
		let leftLabelText = data.first!.0;
		var rightLabelText = data.first!.1;
		
		if leftLabelText == aprPercentLabel {
			rightLabelText = "\(rightLabelText) %";
		} else if (leftLabelText == minimumPaymentLabel || leftLabelText == currentBalanceLabel) {
			rightLabelText = "$\(rightLabelText)";
		}
		
		leftLabel.text = leftLabelText;
		rightLabel.text = rightLabelText;
		
        return cell
    }

}
