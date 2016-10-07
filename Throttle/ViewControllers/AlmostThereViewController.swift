//
//  AlmostThereViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-12-19.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit

class AlmostThereViewController: BaseViewController {
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var aprPercentageText: UITextField!
	@IBOutlet var minimumPaymentText: UITextField!
	@IBOutlet var balanceText: UITextField!
	@IBOutlet var paymentDueText: UITextField!
	
	@IBOutlet var aprErrorLabel: UILabel!
	@IBOutlet var minimumPaymentErrorLabel: UILabel!
	@IBOutlet var balanceErrorLabel: UILabel!
	@IBOutlet var paymentDueErrorLabel: UILabel!
	@IBOutlet var saveButtonVerticalConstraint: NSLayoutConstraint!
	
	var originalScrollViewContentSize : CGSize!;
	var manualLoanInfoModel : ManualLoanInfo!;
	let screenType = UIDeviceInfo.screenType();
	let segueToConfirmAccountInformation = "segueToConfirmAccountInformation";
	let daysOfTheMonth : [Int] = {
		var arrayOfInts : [Int] = [];
		for (var i = 1; i <= 31; i++)
		{
			arrayOfInts.append(i);
		}
		
		return arrayOfInts;
	}();
	var selectedDayOfTheMonthInt : Int = 1;
	
	//MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Adding Information Manually";
		
		self.aprPercentageText.attributedPlaceholder = NSAttributedString(string: self.aprPercentageText.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]);
		self.aprPercentageText.textColor = UIColor.whiteColor();
		
		self.minimumPaymentText.attributedPlaceholder = NSAttributedString(string: self.minimumPaymentText.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]);
		self.minimumPaymentText.textColor = UIColor.whiteColor();
		
		self.balanceText.attributedPlaceholder = NSAttributedString(string: self.balanceText.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]);
		self.balanceText.textColor = UIColor.whiteColor();
		
		self.paymentDueText.attributedPlaceholder = NSAttributedString(string: self.paymentDueText.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()]);
		self.paymentDueText.textColor = UIColor.whiteColor();
		
		self.aprPercentageText.delegate = self;
		self.minimumPaymentText.delegate = self;
		self.balanceText.delegate = self;
		self.paymentDueText.delegate = self;
		
		self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag;
		self.scrollView.alwaysBounceVertical = true;
		
		self.aprErrorLabel.hidden = true;
		self.minimumPaymentErrorLabel.hidden = true;
		self.balanceErrorLabel.hidden = true;
		self.paymentDueErrorLabel.hidden = true;
		
		if (self.screenType == .iPhone6)
		{
			self.saveButtonVerticalConstraint.constant = 520;
		}
		else if (self.screenType == .iPhone5 || self.screenType == .iPhone4)
		{
			self.saveButtonVerticalConstraint.constant = 430;
		}
		
		//load any values that were previously stored
		if let text = self.manualLoanInfoModel.aprPercentage {
			self.aprPercentageText.text = text;
		}
		
		if let text = self.manualLoanInfoModel.minimumPayment {
			self.minimumPaymentText.text = text;
		}
		
		if let text = self.manualLoanInfoModel.minimumPayment {
			self.balanceText.text = text;
		}
		
		if let text = self.manualLoanInfoModel.paymentDueEachMonth {
			self.paymentDueText.text = text;
		}
		
		//add a picker view to the payment due every month textfield
		let picker: UIPickerView
		picker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
		picker.backgroundColor = UIColor.whiteColor()
		
		picker.showsSelectionIndicator = true
		picker.delegate = self
		picker.dataSource = self
		
		let toolBar = UIToolbar()
		toolBar.barStyle = UIBarStyle.Black
		toolBar.translucent = true
		toolBar.sizeToFit()
		
		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
		let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		
		toolBar.setItems([spaceButton, doneButton], animated: false)
		toolBar.userInteractionEnabled = true
		
		self.paymentDueText.inputView = picker
		self.paymentDueText.inputAccessoryView = toolBar
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated);
		self.scrollView.setNeedsLayout();
		self.scrollView.layoutIfNeeded();
		
		self.originalScrollViewContentSize = self.scrollView.contentSize;
	}
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
		self.navigationController!.navigationBar.shadowImage = nil;
		navigationController!.navigationBar.barTintColor = Theme.darkBlueBarColor();
		navigationController!.navigationBar.tintColor = Theme.darkBlueTextColor();
		navigationController!.setNavigationBarHidden(false, animated: true)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - Keyboard events
	override func keyboardWillShow(notification: NSNotification) {
		self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, 800);
	}
	
	override func keyboardWillHide(notification: NSNotification) {
		self.scrollView.contentSize = self.originalScrollViewContentSize;
	}
	
	
	//MARK: - Helpers
	func donePicker() {
		self.paymentDueText.resignFirstResponder();
	}
	
	private func isValid() -> Bool {
		self.aprErrorLabel.hidden = true;
		self.minimumPaymentErrorLabel.hidden = true;
		self.balanceErrorLabel.hidden = true;
		self.paymentDueErrorLabel.hidden = true;
		
		guard let aprTextStr = self.aprPercentageText.text
			where aprTextStr.characters.count > 0
			else
		{
			self.aprErrorLabel.text = "This field is required";
			self.aprErrorLabel.hidden = false;
			return false;
		}
		
		guard let minimumPaymentStr = self.minimumPaymentText.text
			where minimumPaymentStr.characters.count > 0
			else
		{
			self.minimumPaymentErrorLabel.text = "This field is required";
			self.minimumPaymentErrorLabel.hidden = false;
			return false;
		}
		
		guard let balanceTextStr = self.balanceText.text
			where balanceTextStr.characters.count > 0
			else
		{
			self.balanceErrorLabel.text = "This field is required";
			self.balanceErrorLabel.hidden = false;
			return false;
		}
		
		guard let paymentDueStr = self.paymentDueText.text
			where paymentDueStr.characters.count > 0
			else
		{
			self.paymentDueErrorLabel.text = "This field is required";
			self.paymentDueErrorLabel.hidden = false;
			return false;
		}
		
		//validate number values
		let apr = self.getDecimalFromString(aprTextStr);
		if (apr <= 0)
		{
			self.aprErrorLabel.text = "Invalid entry";
			self.aprErrorLabel.hidden = false;
			return false;
		}
		
		let minimumPayment = self.getDecimalFromString(minimumPaymentStr);
		if (minimumPayment <= 0)
		{
			self.minimumPaymentErrorLabel.text = "Invalid entry";
			self.minimumPaymentErrorLabel.hidden = false;
			return false;
		}
		
		let balance = self.getDecimalFromString(balanceTextStr);
		if (balance <= 0)
		{
			self.balanceErrorLabel.text = "Invalid entry";
			self.balanceErrorLabel.hidden = false;
			return false;
		}
		
		self.manualLoanInfoModel.aprPercentage = aprTextStr;
		self.manualLoanInfoModel.minimumPayment = minimumPaymentStr;
		self.manualLoanInfoModel.balance = balanceTextStr;
		self.manualLoanInfoModel.paymentDueEachMonth = paymentDueStr
		
		self.manualLoanInfoModel.aprPercentageDouble = apr;
		self.manualLoanInfoModel.minimumPaymentDouble = minimumPayment;
		self.manualLoanInfoModel.balanceDouble = balance;
		
		self.manualLoanInfoModel.paymentDueEachMonthInt = self.selectedDayOfTheMonthInt;
		
		return true;
	}

	func executeSave() {
		self.view.endEditing(true);
		if (self.isValid()) {
			self.performSegueWithIdentifier(self.segueToConfirmAccountInformation, sender: nil);
		}
	}
	
	//MARK: - Navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//get rid of the back button text, per mock ups
		let backItem = UIBarButtonItem();
		backItem.title = "";
		navigationItem.backBarButtonItem = backItem;
		
		
		if (segue.identifier == self.segueToConfirmAccountInformation)
		{
			let vc = segue.destinationViewController as! ConfirmAccountViewController;
			vc.manualLoanInfoModel = self.manualLoanInfoModel;
		}
	}
	
	//MARK: - Button events
	@IBAction func saveButtonTapped(sender: AnyObject) {
		self.executeSave();
	}
	
	
	func getDecimalFromString(string: String) -> Double {
		return (string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByReplacingOccurrencesOfString(",", withString: "") as NSString).doubleValue;
//		return NSDecimalNumber(string: string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByReplacingOccurrencesOfString(",", withString: ""), locale: NSLocale.currentLocale()).doubleValue;
	}
	
}

//MARK: - UITextfieldDelegate
extension AlmostThereViewController : UITextFieldDelegate
{
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		var yOffset : CGFloat = 0;
		
		if (textField == self.aprPercentageText)
		{
			yOffset = 80;
		}
		else if (textField == self.minimumPaymentText)
		{
			yOffset = 140;
		}
		else if (textField == self.balanceText)
		{
			yOffset = 180;
		}
		else if (textField == self.paymentDueText)
		{
			yOffset = 220;
		}
		
		if (yOffset > 80 && self.screenType == .iPhone6)
		{
			yOffset = 80;
		}
		else if (self.screenType == .iPhone6Plus)
		{
			yOffset = 0;
		}
		
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.scrollView.contentOffset = CGPointMake(0, yOffset);
		});
		
		return true;
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if (textField == self.aprPercentageText)
		{
			self.minimumPaymentText.becomeFirstResponder();
		}
		else if (textField == self.minimumPaymentText)
		{
			self.balanceText.becomeFirstResponder();
		}
		else if (textField == self.balanceText)
		{
			self.paymentDueText.becomeFirstResponder();
		}
		else if (textField == self.paymentDueText)
		{
			self.executeSave();
		}
		
		return true;
	}
}

extension AlmostThereViewController : UIPickerViewDataSource, UIPickerViewDelegate
{
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1;
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return self.daysOfTheMonth.count;
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let text = "\(self.daysOfTheMonth[row])\(self.daysOfTheMonth[row].ordinal)";
		
		self.paymentDueText.text = text;
		self.selectedDayOfTheMonthInt = self.daysOfTheMonth[row];
		
		return text;
	}
	
}
