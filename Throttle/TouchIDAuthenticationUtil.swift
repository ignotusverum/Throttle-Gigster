//
//  TouchIDAuthentication.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import LocalAuthentication;

enum TouchIDAuthResponseResult {
	case Success
	case Error
	case PasswordFallback
}

class TouchIDAuthenticationUtil: NSObject {
	
	func authenticate(completionBlock: (touchIdResponse: TouchIDAuthResponseResult) -> Void) {
		//TODO: Add touch ID based on user preference. Awaiting Kaitlyn's implementation.
		
		let context = LAContext();
		var authError : NSError?;
		let userHasTouchID = context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError);
		if (userHasTouchID) {
			context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Use fingerprint to verify", reply: { (success, error) -> Void in
				
				var touchIdResponse = TouchIDAuthResponseResult.Success;
				
				if let err = error
				{
					if (Int32(err.code) == kLAErrorUserFallback)
					{
						touchIdResponse = .PasswordFallback;
					}
					else {
						touchIdResponse = .Error;
					}
				}
				
				completionBlock(touchIdResponse: touchIdResponse);
			});
		} else {
			completionBlock(touchIdResponse: TouchIDAuthResponseResult.Error);
		}
	}
}
