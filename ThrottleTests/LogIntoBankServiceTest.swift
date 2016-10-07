//
//  LogIntoBankServiceTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import Throttle

class LogIntoBankServiceTest: XCTestCase {
	let auth = MockedAuth();
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBankLoginGetSuccessResult() {
		let expectations = expectationWithDescription("testLogin");
		
		LoginHelper.login(auth) {
			let service = GetBankLoginFormService(auth: self.auth);
			service.execute(self.auth.testBankId, completionHandler: { (result) in
				XCTAssert(result.code == .Success);
				
				let loginService = LoginIntoBankService(un: self.auth.testBankUsername, pw: self.auth.testBankPassword, bankId: self.auth.testBankId, auth: self.auth);
				
				loginService.execute({ (result) -> Void in
					XCTAssert(result.code == StatusCodes.Success);
					XCTAssert(result.message != nil);
					print(result.message!);
				
					expectations.fulfill();
				});
				
			});
		}
		
		waitForExpectationsWithTimeout(10, handler: nil);
    }
	

    
}
