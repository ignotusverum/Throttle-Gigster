//
//  ImprovePlanViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/24/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class ImprovePlanViewController: UIViewController {
	@IBOutlet var totalMonthlyPaymentLabel: UILabel!
	@IBOutlet var totalPeriodOfTimeLabel: UILabel!
	@IBOutlet var totalDebtLabel: UILabel!
	@IBOutlet var totalInterestLabel: UILabel!
	@IBOutlet var totalMonthlyPaymentMinusButton: UIButton!
	@IBOutlet var totalMonthlyPaymentPlusButton: UIButton!

	@IBOutlet var periodOfTimePlusButton: UIButton!
	@IBOutlet var periodOfTimeMinusButton: UIButton!
	
	let updateMinimumPaymentIncrement : Int = Int.convertToCents(5)
	var theMinimumPaymentPossible : Int = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.totalMonthlyPaymentLabel.text = "--"
		self.totalPeriodOfTimeLabel.text = "--"
		self.totalDebtLabel.text = "--"
		self.totalInterestLabel.text = "--"
		
		self.totalMonthlyPaymentLabel.alpha = 0
		self.totalPeriodOfTimeLabel.alpha = 0
		self.totalDebtLabel.alpha = 0
		self.totalInterestLabel.alpha = 0
		
		self.totalMonthlyPaymentPlusButton.enabled = false
		self.totalMonthlyPaymentMinusButton.enabled = false
		self.periodOfTimeMinusButton.enabled = false
		self.periodOfTimePlusButton.enabled = false
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let calculationAlgorithm = NSUserDefaults.getCalculationAlgorithm()
            
			let accountDataService = GetLoanAndCreditAccountsService().getAccounts()
            if (accountDataService.code != .Success) {
                dispatch_async(dispatch_get_main_queue()) {
                    let vc = AlertUtil.getSimpleAlert("Error", message: "There was an error retrieving your account data. Please try again later. If the problem persists, please log out and log back in.")
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            } else {
                // If the user's desired monthly payment is less than the combined minimum payment of all their accounts, update the monthly
                //   payment to match the total
                if NSUserDefaults.getTotalMonthlyMinimumPayment() < accountDataService.totalMinimumPayments {
                    NSUserDefaults.setTotalMonthlyMinimumPayment(accountDataService.totalMinimumPayments)
                }
                
                let paymentServiceData = SnowballAvalancheCalculationService(logDetails: true).executeWithSnowballAlgorithm(calculationAlgorithm, withTotalMonthlyPayment: NSUserDefaults.getTotalMonthlyMinimumPayment())
                
                self.theMinimumPaymentPossible = accountDataService.totalMinimumPayments
                
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(0.2, animations: {
                        self.totalDebtLabel.alpha = 1
                        self.totalInterestLabel.alpha = 1
                        self.totalMonthlyPaymentLabel.alpha = 1
                        self.totalPeriodOfTimeLabel.alpha = 1
                    })
                    
                    self.updateDisplay(accountData: accountDataService, paymentData: paymentServiceData)
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func buildTotalPayoffTimeString(totalNumberOfMonthsToPayOff: Int) -> String {
        var timeLeftToPayOffBills = ""
        
        let yearsToPayOff = totalNumberOfMonthsToPayOff / 12
        if yearsToPayOff > 0 {
            timeLeftToPayOffBills += "\(yearsToPayOff) Y "
        }
        
        let monthsToPayOff = totalNumberOfMonthsToPayOff % 12
        if monthsToPayOff > 0 {
            timeLeftToPayOffBills += "\(monthsToPayOff) M"
        }
        
        return timeLeftToPayOffBills
    }
	
	private func recalculatePlan() {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let calculationAlgorithm = NSUserDefaults.getCalculationAlgorithm()
			let paymentServiceData = SnowballAvalancheCalculationService(logDetails: false).executeWithSnowballAlgorithm(calculationAlgorithm, withTotalMonthlyPayment: NSUserDefaults.getTotalMonthlyMinimumPayment())
			let accountDataService = GetLoanAndCreditAccountsService().getAccounts()
			
			let timeLeftToPayOffBills = self.buildTotalPayoffTimeString(paymentServiceData.numberOfMonthsToPayOff)
			
			dispatch_async(dispatch_get_main_queue(), {
				self.updateDisplay(accountData: accountDataService, paymentData: paymentServiceData)
			})
		}
	}
    
    private func updateDisplay(accountData accountData: GetLoansAndCreditAccountsResult, paymentData: SnowballAvalancheCalculationResult) {
        let minimumPayment = NSUserDefaults.getTotalMonthlyMinimumPayment()
        self.totalMonthlyPaymentLabel.text = accountData.formatter.stringFromNumber(
            Int.convertToCurrency(minimumPayment)
        )
        
        let canDecreaseMinimumPayment = minimumPayment > self.theMinimumPaymentPossible
        
        self.totalMonthlyPaymentPlusButton.enabled = true
        self.totalMonthlyPaymentMinusButton.enabled = canDecreaseMinimumPayment
        self.periodOfTimeMinusButton.enabled = true
        self.periodOfTimePlusButton.enabled = canDecreaseMinimumPayment
        
        // Update interest labels, or show an error message if our interest calculations were inaccurate
        if (paymentData.code == .Success) {
            self.totalDebtLabel.text = accountData.formatter.stringFromNumber(Int.convertToCurrency(accountData.totalPrincipleBalance + paymentData.interestPaid))
            self.totalInterestLabel.text = accountData.formatter.stringFromNumber(Int.convertToCurrency(paymentData.interestPaid))
            self.totalPeriodOfTimeLabel.text = self.buildTotalPayoffTimeString(paymentData.numberOfMonthsToPayOff)
        } else {
            self.totalDebtLabel.text = "--"
            self.totalInterestLabel.text = "--"
            self.totalPeriodOfTimeLabel.text = "--"
            
            let vc = AlertUtil.getSimpleAlert("Error", message: "There was an error performing interest calculations: \(paymentData.message ?? "\(paymentData.code.rawValue)")")
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
	
	@IBAction func closeButtonTapped(sender: AnyObject) {
        let updatePaymentService = UpdateMonthlyPaymentService(auth: ConfigFactory.getAuth())
        updatePaymentService.execute(NSUserDefaults.getTotalMonthlyMinimumPayment()) { (success) in
            print(success ? "Stored monthly payment updated." : "Stored monthly payment failed to update.")
        }
        
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func totalMonthlyPaymentMinusButtonTapped(sender: AnyObject) {
		let update = updateMinimumPaymentIncrement * -1
		self.updateMinimumPayment(update)
	}
	
	@IBAction func totalMonthlyPaymentPlusButtonTapped(sender: AnyObject) {
		self.updateMinimumPayment(self.updateMinimumPaymentIncrement)
	}
	
	@IBAction func periodOfTimeMinusButtonTapped(sender: AnyObject) {
		self.updateMinimumPayment(self.updateMinimumPaymentIncrement)
	}
	
	@IBAction func periodOfTimePlusButtonTapped(sender: AnyObject) {
		let update = updateMinimumPaymentIncrement * -1
		self.updateMinimumPayment(update)
	}
	
	
	func updateMinimumPayment(difference: Int) {
		let currentMonthlyPayment = max(theMinimumPaymentPossible, NSUserDefaults.getTotalMonthlyMinimumPayment() + difference)
		
		let numberFormatter = NSNumberFormatter()
		numberFormatter.numberStyle = .CurrencyStyle
		
		self.totalMonthlyPaymentLabel.text = numberFormatter.stringFromNumber(
			Int.convertToCurrency(currentMonthlyPayment)
		)
		
		NSUserDefaults.setTotalMonthlyMinimumPayment(currentMonthlyPayment)
		
		if (currentMonthlyPayment <= theMinimumPaymentPossible) {
			self.totalMonthlyPaymentMinusButton.enabled = false
			self.periodOfTimePlusButton.enabled = false
		}
		else {
			self.totalMonthlyPaymentMinusButton.enabled = true
			self.periodOfTimePlusButton.enabled = true
		}
		
		self.recalculatePlan()
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
