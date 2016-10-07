//
//  LoginServiceUnitTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
@testable import Throttle

class LoginServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin_getSuccessResult() {
		let manager = ThrottleCommunicationsManager();
		let expectations = expectationWithDescription("testLogin");
		let auth = MockedAuth();
		
		manager.signIn(auth.debugUsername, password: auth.debugPassword, auth:auth) { (user, error) -> Void in
			XCTAssert(error == nil);
			XCTAssert(auth.isUserLoggedIn());
			
			expectations.fulfill();
		}
		
		waitForExpectationsWithTimeout(10, handler: nil);
    }
	
	func testLogin_getError() {
		let manager = ThrottleCommunicationsManager();
		let expectations = expectationWithDescription("testLogin");
		let auth = MockedAuth();
		
		manager.signIn(auth.debugUsername, password: "123123123", auth:auth) { (user, error) -> Void in
			XCTAssert(error != nil);
			XCTAssert(auth.isUserLoggedIn() == false);
			
			expectations.fulfill();
		}
		
		waitForExpectationsWithTimeout(10, handler: nil);
	}
	
}
