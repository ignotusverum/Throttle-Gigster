//
//  CommonButton.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/17/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

@IBDesignable
class CommonButton: UIButton {
	@IBInspectable var theBackgroundColor : UIColor = UIColor ( red: 13/255.0, green: 93/255.0, blue: 144/255.0, alpha: 1.0 );
	@IBInspectable var theTintColor : UIColor = UIColor.whiteColor();
	@IBInspectable var fontSize : CGFloat = 16;
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!;
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	func customize() {
		self.layer.backgroundColor = self.theBackgroundColor.CGColor;
		self.layer.cornerRadius = self.layer.frame.height / 2;
		self.clipsToBounds = true;
		self.titleLabel?.font = UIFont(name: "KohinoorBangla-Regular", size: fontSize);
		self.tintColor = theTintColor;
		
		self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled);
	}
	
	override func drawRect(rect: CGRect) {
		self.customize();
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.customize();
	}
	
}
