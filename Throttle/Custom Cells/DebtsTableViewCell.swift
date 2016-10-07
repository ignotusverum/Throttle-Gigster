//
//  DebtsTableViewCell.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/4/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class DebtsTableViewCell: UITableViewCell {
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var accountCardLabel: UILabel!
  @IBOutlet weak var monthLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
