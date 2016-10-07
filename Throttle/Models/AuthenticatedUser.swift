//
//  AuthenticatedUser.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/21/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class AuthenticatedUser: NSObject {
	let password : String;
	let token : String;
	
	
	init(password: String, token: String) {
		self.password = password;
		self.token = token;
	}
}
