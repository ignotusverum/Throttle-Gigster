//
//  LoginHelper.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
@testable import Throttle

class LoginHelper: NSObject {
	static func login(auth: MockedAuth, completionBlock: () -> Void) {
		let manager = ThrottleCommunicationsManager();
		
		manager.signIn(auth.debugUsername, password: auth.debugPassword, auth:auth) { (user, error) -> Void in
			if (!auth.isUserLoggedIn()) {
				fatalError("User should be logged in!");
			}
			
			completionBlock();
		};
	}
	
}
