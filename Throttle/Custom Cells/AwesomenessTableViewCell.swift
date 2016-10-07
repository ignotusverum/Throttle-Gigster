//
//  AwesomenessTableViewCell.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2016-01-03.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class AwesomenessTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
