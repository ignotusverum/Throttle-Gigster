//
//  TouchIDTableViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class TouchIDTableViewController: UITableViewController {
  
  let kTouchIDCellIdentifier = "touchIDCellIdentifier"
  var settingsService:SettingsService!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      let auth = ConfigFactory.getAuth();
      settingsService = SettingsService(auth: auth)

    }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableTouchID:", name: "enableTouchIDNotification", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableTouchID:", name: "disableTouchIDNotification", object: nil)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidAppear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "enableTouchIDNotification:", object: nil)
     NSNotificationCenter.defaultCenter().removeObserver(self, name: "disableTouchIDNotification:", object: nil)
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTouchIDCellIdentifier, forIndexPath: indexPath) as! TouchIDSettingTableViewCell
      cell.backgroundColor = tableViewCellDarkerBlue()
      cell.enableTouchIDSwitch.on = settingsService.isTouchIDEnabledOrSet()
        // Configure the cell...

        return cell
    }
  
  func enableTouchID(notification:NSNotification) {
    self.saveTouchIDSetting(true)
	let controller = AlertUtil.getSimpleAlert("Touch ID", message: "Touch ID has been activated. You will be asked for your fingerprint the next time you open the app.");
	self.presentViewController(controller, animated: true, completion: nil);
  }
  
  func disableTouchID(notification:NSNotification) {
    self.saveTouchIDSetting(false)
  }
  
  func saveTouchIDSetting(enable:Bool) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      self.settingsService.setTouchIDEnabled(enable);
    };
  }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
