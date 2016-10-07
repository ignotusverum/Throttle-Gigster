//
//  BaseViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/18/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
	var originalViewFrame : CGRect!;
	var currentKeyboardHeight : CGFloat = 0;
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated);
		self.currentKeyboardHeight = 0;
		if (self.originalViewFrame == nil) {
			self.originalViewFrame = self.view.frame;
		}
	}
	
	
	// MARK: - Keyboard Notifications
	func keyboardWillShow(notification: NSNotification) {
		let userInfo = notification.userInfo! as NSDictionary
		let keyboardFrameValue: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey)as! NSValue
		let rect = keyboardFrameValue.CGRectValue()
		
		var frame = self.view.frame;
		frame.origin.y = frame.origin.y - (rect.height - self.currentKeyboardHeight)
		
		
		self.view.frame = frame
		self.currentKeyboardHeight = rect.height;
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if (self.originalViewFrame == nil) {return};
		self.view.frame = self.originalViewFrame;
		self.currentKeyboardHeight = 0;
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self);
		print("deinit called");
	}
}
