//
//  MockedAuth.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
@testable import Throttle

class MockedAuth: NSObject, AuthProtocol {
	static var user : AuthenticatedUser?;
	let debugUsername = "m4rcoperuano@gmail.com";
	let debugChangeEmail = "kaitlynlee19@gmail.com";
	let debugPassword = "castle12";
	
	//DagBankSeCUrityQA
	let testBankId = 12288;
	let testBankUsername = "marcotest.Loans1";
	let testBankPassword = "Loans1";
	
	func getAuthenticatedUser() -> AuthenticatedUser? {
		return MockedAuth.user;
	}
	
	func setAuthenticatedUser(user: AuthenticatedUser) -> Bool {
		MockedAuth.user = user;
		return true;
	}
	
	func removeAuthenticatedUserData() {
		MockedAuth.user = nil;
	}
	
	func isUserLoggedIn() -> Bool {
		return MockedAuth.user != nil;
	}
	
	func getAuthenticatedUsingTouchID() -> Bool {
		return false;
	}
	
	func setAuthenticatedUsingTouchID(authenticated: Bool) {
		//intentionally do nothing
	}
}
