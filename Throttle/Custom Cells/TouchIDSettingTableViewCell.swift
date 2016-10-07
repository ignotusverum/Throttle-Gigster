//
//  TouchIDSettingTableViewCell.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class TouchIDSettingTableViewCell: UITableViewCell {

  @IBOutlet weak var enableTouchIDSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  @IBAction func switchToggled(sender: AnyObject) {
    if (self.enableTouchIDSwitch.on) {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("enableTouchIDNotification", object: nil)
        
      });

    } else {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("disableTouchIDNotification", object: nil)
        
      });
    }
  }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
