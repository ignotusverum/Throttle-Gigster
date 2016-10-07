//
//  WelcomePlusButton.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/21/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class WelcomePlusButton: UIButton {
	var circle1 :CAShapeLayer!;
	var circle2 :CAShapeLayer!;
	
	var diameterOfCircle : CGFloat = 0;
	var radius : CGFloat = 0;
	
	var diameterOfCircle2 : CGFloat = 0;
	var radius2 : CGFloat = 0;

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		self.alpha = 0.9;
		self.clipsToBounds = false;
		self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit;
		self.contentMode = UIViewContentMode.ScaleAspectFit;
		
		self.setImage(UIImage(named: "plus_button-tapped"), forState: UIControlState.Highlighted);
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "beginAnimation", name: NSNotificationName.beginWelcomeButtonAnimation.rawValue, object: nil);
	}
	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
		
		let image = UIImage(named: "plus_button");
		let imageRef = CGImageCreateWithImageInRect(image!.CGImage!, CGRectMake(0,0,312,313))!;
		let imageRefImage = UIImage(CGImage: imageRef);
		
		UIGraphicsBeginImageContext(CGSizeMake(312, 313));
		imageRefImage.drawAtPoint(CGPointZero, blendMode:CGBlendMode.SoftLight, alpha:1);
		let newImage = UIGraphicsGetImageFromCurrentImageContext();
		self.setImage(newImage, forState: UIControlState.Normal);
		UIGraphicsEndImageContext();
		
		
		//Create circles
		let rectWidth = rect.size.width;
		let rectHeight = rect.size.height;
		self.diameterOfCircle = rectWidth;
		self.radius = self.diameterOfCircle / 2;
		
		let backgroundColorOfCircle = UIColor (red: 0.228, green: 0.8249, blue: 0.1152, alpha: 0.47).CGColor;
		
		circle1 = CAShapeLayer();
		circle1.position = CGPointMake(rectWidth / 2 - radius, rectHeight / 2 - radius);
		circle1.opacity = 0.8;
		circle1.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, diameterOfCircle, diameterOfCircle)).CGPath;
		circle1.fillColor = backgroundColorOfCircle;
		circle1.anchorPoint = CGPointZero;
		self.layer.insertSublayer(circle1, atIndex: 0);
		
		
		self.diameterOfCircle2 = diameterOfCircle;
		self.radius2 = diameterOfCircle2 / 2;
		
		circle2 = CAShapeLayer();
		circle2.position = CGPointMake(rectWidth / 2 - radius2, rectWidth / 2 - radius2);
		circle2.opacity = 0;
		circle2.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, diameterOfCircle2, diameterOfCircle2)).CGPath;
		circle2.fillColor = backgroundColorOfCircle;
		circle2.anchorPoint = CGPointZero;
		self.layer.insertSublayer(circle2, atIndex: 0);
    }
	

	
	func beginAnimation() {
		NSNotificationCenter.defaultCenter().removeObserver(self);
		
		let rectWidth = self.frame.width;
		let rectHeight = self.frame.height;
		let animDuration : CFTimeInterval = 3;
		
		var scaleAnimation = CABasicAnimation(keyPath: "transform.scale");
		scaleAnimation.repeatCount = .infinity;
		scaleAnimation.removedOnCompletion = false;
		scaleAnimation.fillMode = kCAFillModeForwards;
		scaleAnimation.duration = animDuration;
		scaleAnimation.fromValue = NSValue.init(CGPoint: CGPointMake(1, 1));
		scaleAnimation.toValue = NSValue.init(CGPoint: CGPointMake(2, 2));
		circle1.addAnimation(scaleAnimation, forKey: "transform.scale");
		
		let opacityAnimation = CABasicAnimation(keyPath: "opacity");
		opacityAnimation.repeatCount = .infinity;
		opacityAnimation.removedOnCompletion = false;
		opacityAnimation.fillMode = kCAFillModeForwards;
		opacityAnimation.duration = animDuration;
		opacityAnimation.fromValue = NSValue.init(CGPoint: CGPointMake(0.7, 0.7));
		opacityAnimation.toValue = NSValue.init(CGPoint: CGPointMake(0, 0));
		circle1.addAnimation(opacityAnimation, forKey: "opacity");
		
		var positionAnimation = CABasicAnimation(keyPath: "position");
		positionAnimation.repeatCount = .infinity;
		positionAnimation.removedOnCompletion = false;
		positionAnimation.fillMode = kCAFillModeForwards;
		positionAnimation.duration = animDuration;
		positionAnimation.fromValue = NSValue.init(CGPoint: CGPointMake(rectWidth / 2 - radius, rectHeight / 2 - radius));
		positionAnimation.toValue = NSValue.init(CGPoint: CGPointMake(radius * -1.0, radius * -1.0));
		circle1.addAnimation(positionAnimation, forKey: "position");
		
		
		
		// Delay execution of my block for 10 seconds.
		let delay = 1.5 * Double(NSEC_PER_SEC)
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
		dispatch_after(time, dispatch_get_main_queue()) {
			
			scaleAnimation = CABasicAnimation(keyPath: "transform.scale");
			scaleAnimation.repeatCount = .infinity;
			scaleAnimation.removedOnCompletion = false;
			scaleAnimation.fillMode = kCAFillModeForwards;
			scaleAnimation.duration = animDuration;
			scaleAnimation.fromValue = NSValue.init(CGPoint: CGPointMake(1, 1));
			scaleAnimation.toValue = NSValue.init(CGPoint: CGPointMake(2, 2));
			self.circle2.addAnimation(scaleAnimation, forKey: "transform.scale");
			
			positionAnimation = CABasicAnimation(keyPath: "position");
			positionAnimation.repeatCount = .infinity;
			positionAnimation.removedOnCompletion = false;
			positionAnimation.fillMode = kCAFillModeForwards;
			positionAnimation.duration = animDuration;
			positionAnimation.fromValue = NSValue.init(CGPoint: CGPointMake(rectWidth / 2 - self.radius2, rectHeight / 2 - self.radius2));
			positionAnimation.toValue = NSValue.init(CGPoint: CGPointMake(self.radius2 * -1.0, self.radius2 * -1.0));
			
			self.circle2.addAnimation(positionAnimation, forKey: "position");
			self.circle2.addAnimation(opacityAnimation, forKey: "opacity");
		}
	}
}
