//
//  EditDebtTableViewCell.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

enum ValueType {
  case Money
  case Date
  case Percent
  case None
}

class EditDebtTableViewCell: UITableViewCell {
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var unitTextLabel: UILabel!
  
  var datePicker = UIDatePicker()
  
  var type = ValueType.None
  var valueToDisplay = NSNumber()
  var value2ToDisplay = NSNumber()
  var accountKey:AccountKey!
  var allowEditing:Bool = true
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
    self.textField.leftView = paddingView
    self.textField.leftViewMode = UITextFieldViewMode.Always
    self.textField.addTarget(self, action: "textFieldEditingEnded:", forControlEvents: UIControlEvents.EditingDidEnd)
    
    self.datePicker.datePickerMode = .Date
    self.datePicker.addTarget(self, action: "handleDatePicker:", forControlEvents: .ValueChanged)
    //    if (self.allowEditing == false) {
    //      self.textField.allowsEditingTextAttributes = false
    //    }
  }
  
  func disableField() {
    self.textField.enabled = false
    self.textField.textColor = UIColor.grayColor()
    self.allowEditing = false
  }
  
  func enableField() {
    self.textField.enabled = true
    self.textField.textColor = UIColor.blackColor()
    self.allowEditing = true
  }
  
  func textFieldEditingEnded(textField:UITextField) {
    self.saveOutValue()
  }
  
  func saveOutValue() {
    if (self.allowEditing == true) {
      if (self.type == .Date) {
        let calendar = NSCalendar.currentCalendar()
        
        let unitFlags: NSCalendarUnit = [.Month, .Day]
        
        let components = calendar.components(unitFlags, fromDate: datePicker.date)
        self.valueToDisplay = components.month - 1
        self.value2ToDisplay = components.day
        
        NSNotificationCenter.defaultCenter().postNotificationName("DetailChangedValueNotification", object: self, userInfo: ["key": self.accountKey.rawValue, "value1": self.valueToDisplay.doubleValue, "value2":self.value2ToDisplay.doubleValue])
      } else {
        //      let valueString = self.textField.text!
        self.valueToDisplay = Double(self.textField.text!)!
        NSNotificationCenter.defaultCenter().postNotificationName("DetailChangedValueNotification", object: self, userInfo: ["key": self.accountKey.rawValue, "value1": self.valueToDisplay.doubleValue])
      }
    }
  }
  
  func handleDatePicker(sender:UIDatePicker) {
    if (self.type == .Date) {
      self.updateDateLabel()
    }
  }
  
  func updateDateLabel() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MMMM dd"
    self.textField.text = dateFormatter.stringFromDate(datePicker.date)
  }
  
  func setValuesAndDisplay(first:NSNumber, second:NSNumber, type:ValueType, accountKey:AccountKey) {
    self.accountKey = accountKey
    self.valueToDisplay = first
    self.value2ToDisplay = second
    self.type = type
    switch self.type {
    case .Money:
      self.textField.text = String(format: "%.02f", self.valueToDisplay.doubleValue)
      self.unitTextLabel.text = "$"
      break
    case .Date:
      self.setUpDatePicker()
      break
    case .Percent:
      self.textField.text = String(format: "%.02f", self.valueToDisplay.doubleValue)
      self.unitTextLabel.text = "%"
      break
    case .None:
      self.textField.text = ""
      self.unitTextLabel.text = ""
      break
    }
  }
  
  func setUpDatePicker() {
    var notSet = false;
    if (self.value2ToDisplay.integerValue == 0 || self.valueToDisplay.integerValue == 0) {
      notSet = true;
    }
    self.textField.text =  String(format: "%@ %i", AccountsData.sharedAccountsData.monthTitles[self.valueToDisplay.integerValue], self.value2ToDisplay.integerValue)
    self.unitTextLabel.text = ""
    self.textField.inputView = self.datePicker
    
    let calendar = NSCalendar.currentCalendar()
    let now = NSDate()
    let components = calendar.components(NSCalendarUnit.Year, fromDate: now)
    if (!notSet) {
      components.month = self.valueToDisplay.integerValue + 1
      components.day = self.value2ToDisplay.integerValue
    }
    
    let date = calendar.dateFromComponents(components)
    self.datePicker.setDate(date!, animated: false)
    self.updateDateLabel()
    
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    let touch = event?.allTouches()?.first
    if (self.textField.isFirstResponder() && touch!.view != self.textField) {
      self.textField.resignFirstResponder()
    }
  }
}
