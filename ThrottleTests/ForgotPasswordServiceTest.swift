//
//  ForgotPasswordUnitTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
@testable import Throttle

class ForgotPasswordServiceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testForgotPassword_getSuccessResult() {
		let service = ForgotPasswordService(email:MockedAuth().debugUsername);
		let expectations = expectationWithDescription("testLogin");
		
		service.execute { (success) -> Void in
			XCTAssert(success == true);
			expectations.fulfill();
		}
		
		
		waitForExpectationsWithTimeout(10, handler: nil);
    }
	
	func testForgotPassword_getErrorResult() {
		let service = ForgotPasswordService(email:"somefunkyemail@gmail.com");
		let expectations = expectationWithDescription("testLogin");
		
		service.execute { (success) -> Void in
			XCTAssert(success != true);
			expectations.fulfill();
		}
		
		
		waitForExpectationsWithTimeout(10, handler: nil);
	}
	
}
