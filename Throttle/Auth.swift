//
//  Auth.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/18/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import Locksmith;

class Auth: NSObject, AuthProtocol {
	private let userKey = "userKey";
	private let passwordKey = "passwordKey";
	private let tokenKey = "tokenKey";
	
	private static var cachedUser : AuthenticatedUser?;
	private static var authenticatedUsingTouchID = false;
	
	func getAuthenticatedUser() -> AuthenticatedUser? {
		if let cachedUser = Auth.cachedUser {
			return cachedUser;
		}
		
		var authUser : AuthenticatedUser?;
		
		if let dictionary = Locksmith.loadDataForUserAccount(self.userKey) {
			guard let token = dictionary[self.tokenKey] as? String else {
				return nil;
			}
			                                                                                                                                                                                                                                                                                                              
			guard let password = dictionary[self.passwordKey] as? String else {
				return nil;
			}
			
			authUser = AuthenticatedUser(password: password, token: token);
			Auth.cachedUser = authUser;
		}
		
		return authUser;
	}
	
	func setAuthenticatedUser(user: AuthenticatedUser) -> Bool {
		do {
			self.removeAuthenticatedUserData();
			try Locksmith.saveData([self.tokenKey: user.token, self.passwordKey: user.password], forUserAccount: self.userKey);
			Auth.cachedUser = user;
			return true;
		}
		catch {
			return false;
		}
	}
	
	func removeAuthenticatedUserData() {
		do {
			Auth.cachedUser = nil;
			try Locksmith.deleteDataForUserAccount(self.userKey);
		}
		catch {
			
		}
	}
	
	
	func isUserLoggedIn() -> Bool {
		return self.getAuthenticatedUser() != nil;
	}
	
	func getAuthenticatedUsingTouchID() -> Bool {
		return Auth.authenticatedUsingTouchID;
	}
	
	func setAuthenticatedUsingTouchID(authenticated: Bool) {
		Auth.authenticatedUsingTouchID = authenticated;
	}
}
