//
//  AccountSettingsViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/28/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import LocalAuthentication

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let accountSettingsCellIdentifier = "accountSettingsCellIdentifier";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the cell separator lines for empty cells
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension AccountSettingsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isTouchIDAvailable()) {
            return SettingsData.accountSettingCategories.count
        }
        
        return SettingsData.accountSettingCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(accountSettingsCellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = SettingsData.accountSettingCategories[indexPath.row];
        
        cell.backgroundColor = (indexPath.row % 2 != 0) ? tableViewCellDarkerBlue() : tableViewCellLighterBlue()
        
        if (indexPath.row == 3) {
            
            let notifSwitch = UISwitch()
            notifSwitch.setOn(NSUserDefaults.getCalculationAlgorithm() == CalculationAlgorithm.LowestBalanceFirst, animated: false)
            notifSwitch.addTarget(self, action: #selector(AccountSettingsViewController.toggledAlgorithmSetting(_:)), forControlEvents: UIControlEvents.ValueChanged)
            cell.accessoryView = notifSwitch
        }
        
        return cell
    }
    
    func toggledAlgorithmSetting(sender: UISwitch) {
        NSUserDefaults.setCalculationAlgorithm(sender.on ? CalculationAlgorithm.LowestBalanceFirst : CalculationAlgorithm.HighestAprFirst)
    }
    
    func isTouchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            return true
        }
        return false
    }
}

extension AccountSettingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Selected", SettingsData.accountSettingCategories[indexPath.row])
        switch (indexPath.row) {
        case 0:
            self.performSegueWithIdentifier("changeEmailSegue", sender: nil)
            break
        case 1:
            self.performSegueWithIdentifier("changePasswordSegue", sender: nil)
            break
        case 2:
            self.performSegueWithIdentifier("touchIDSegue", sender: nil)
            break
        case 3:
            // don't need to segue for the algorithm setting cell
            break;
        default:
            break
            
        }
    }
}