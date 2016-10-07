//
//  SavingsPlanAccountView.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

protocol SavingsPlanAccountViewDelegate {
	func didTapOnSavingsPlan(entity: UserAccountEntity);
}

class SavingsPlanAccountView: UIView {
	@IBOutlet var shadowView: UIView!
	@IBOutlet var backgroundColorShadeView: UIView!
	@IBOutlet var callButton: UIButton!
	@IBOutlet var accountNameLabel: UILabel!
	
	var delegate : SavingsPlanAccountViewDelegate?;
	
	var userAccountEntity : UserAccountEntity!;
	
	static func initFromNib() -> SavingsPlanAccountView {
		return NSBundle.mainBundle().loadNibNamed("SavingsPlanAccountView", owner: self, options: nil)![0] as! SavingsPlanAccountView;
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		
	}
	
	@IBAction func callButtonTapped(sender: AnyObject) {
		if let d = delegate {
			d.didTapOnSavingsPlan(self.userAccountEntity);
		}
	}
	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
		shadowView.layer.shadowOpacity = 0.3;
		shadowView.layer.shadowRadius = 10;
		shadowView.layer.shadowOffset = CGSizeMake(0, 0);
		shadowView.layer.shadowColor = UIColor.blackColor().CGColor;
		shadowView.layer.shouldRasterize = true;
    }

}
