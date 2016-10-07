//
//  DashboardCard.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/14/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

enum CardType {
	case TotalInterest
	case TotalBalance
	case GrandTotal
	case TotalMonthlyPayments
}

protocol DashboardCardProtocol {
	func tappedOnCard(card: DashboardCard);
}

class DashboardCard: UIView {
	static let NibName = "DashboardCard";
	
	let titleLabelYConstant = CGFloat(-100);
	var delegate : DashboardCardProtocol?;
	var index = 0;
	var originalYOffset : CGFloat = 0;
	
	@IBOutlet var collapsedDetailLabel: UILabel!
	@IBOutlet var collapsedTitleLabel: UILabel!
	@IBOutlet var shadowView: UIView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var totalAmountLabel: UILabel!
	@IBOutlet var cardBackgroundView: UIView!
	@IBOutlet var titleLabelYConstraint: NSLayoutConstraint!
	var cardTapped = false;
	var cardType : CardType!;
	
	
	func updateWithCardType(cardType: CardType) {
		self.cardType = cardType;
		self.titleLabel.font = UIFont(name: "KohinoorBangla-Regular", size: self.getSmallFontSize())!;
		self.backgroundImageView.contentMode = UIViewContentMode.ScaleToFill;
		
		var backgroundImage :UIImage!;
		var backgroundColor : UIColor!;
		var titleText : String!;
		var priceText : String!;
		
		switch(cardType) {
		case .GrandTotal:
			//backgroundColor = Theme.dashboardCardGrandTotalBackgroundColor();
			backgroundImage = UIImage(named: "green_card");
			titleText = "Total Principal and Interest on all of your accounts";
			priceText = "$0.00";
			break;
		case .TotalBalance:
			//backgroundColor = Theme.dashboardCardTotalBalanceBackgroundColor();
			backgroundImage = UIImage(named: "blue_card");
			titleText = "Principal Balance for all your accounts";
			priceText = "$0.00";
			break;
		case .TotalInterest:
			//backgroundColor = Theme.dashboardCardTotalInterestBackgroundColor();
			backgroundImage = UIImage(named: "red_card");
			titleText = "Total Interest you owe on all of your accounts";
			priceText = "$0.00";
			break;
		case .TotalMonthlyPayments:
			//backgroundColor = Theme.dashboardCardTotalMonthlyPaymentsBackgroundColor();
			backgroundImage = UIImage(named: "dark_card");
			titleText = "Total of all minimum payments for your accounts";
			priceText = "$0.00";
			break;
		}
		
		self.cardBackgroundView.backgroundColor = backgroundColor;
		self.backgroundImageView.image = backgroundImage;
		self.collapsedTitleLabel.text = priceText;
		self.collapsedDetailLabel.text = titleText;
		self.titleLabel.text = titleText;
		self.totalAmountLabel.text = priceText;
		self.titleLabel.hidden = true;
		self.totalAmountLabel.hidden = true;
		
		let tapGesture = UITapGestureRecognizer(target: self, action: "tappedOnCard");
		self.cardBackgroundView.addGestureRecognizer(tapGesture);
		
		self.backgroundColor = self.cardBackgroundView.backgroundColor;
		self.backgroundImageView.hidden = false;
		
		let swipeGesture = UISwipeGestureRecognizer(target: self, action: "swipedDown");
		swipeGesture.direction = UISwipeGestureRecognizerDirection.Down;
		self.cardBackgroundView.addGestureRecognizer(swipeGesture);
		
		
		
		self.shadowView.layer.shadowOffset = CGSizeMake(0, -2);
		self.shadowView.layer.shadowOpacity = 0.7;
		self.shadowView.layer.shadowRadius = 10;
		self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor;
		self.shadowView.layer.shouldRasterize = true;
		
	}
	
	func tappedOnCard() {
		self.titleLabel.hidden = true;
		self.totalAmountLabel.hidden = true;
		self.collapsedDetailLabel.hidden = true;
		self.collapsedTitleLabel.hidden = true;
		
		self.cardTapped = !self.cardTapped;
		
		if (!self.cardTapped) {
			self.titleLabel.font = UIFont(name: "KohinoorBangla-Regular", size: self.getSmallFontSize())!;
			self.collapsedDetailLabel.hidden = false;
			self.collapsedTitleLabel.hidden = false;
		}
		else {
			self.titleLabel.font = UIFont(name: "KohinoorBangla-Regular", size: 31)!;
			self.titleLabel.hidden = false;
			self.totalAmountLabel.hidden = false;
		}
		
		if let d = delegate {
			d.tappedOnCard(self);
		}
	}
	
	func swipedDown() {
		if (self.cardTapped) {
			self.tappedOnCard();
		}
	}
	
	func updateTotal(value: Int) {
		let formatter = NSNumberFormatter();
		formatter.numberStyle = .CurrencyStyle;
		
		
		let num : Double = Int.convertToCurrency(value);
		
		self.totalAmountLabel.text = formatter.stringFromNumber(num);
		self.collapsedTitleLabel.text = self.totalAmountLabel.text;
	}
	
	private func getSmallFontSize() -> CGFloat {
		let screen = UIDeviceInfo.screenType();
		
		if (screen == .iPhone4 || screen == .iPhone5)
		{
			return 15;
		}
		
		return 18;
	}
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
