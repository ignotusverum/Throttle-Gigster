//
//  AuthProtocol.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

protocol AuthProtocol {
	func getAuthenticatedUser() -> AuthenticatedUser?;
	func setAuthenticatedUser(user: AuthenticatedUser) -> Bool;
	func removeAuthenticatedUserData();
	func isUserLoggedIn() -> Bool;
	
	func getAuthenticatedUsingTouchID() -> Bool;
	func setAuthenticatedUsingTouchID(authenticated: Bool);
}
