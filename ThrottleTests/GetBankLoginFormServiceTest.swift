//
//  GetBankLoginFormServiceTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/1/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
@testable import Throttle

class GetBankLoginFormServiceTest: XCTestCase {
	let auth = MockedAuth();
    
    func testService_getSuccessResult() {
		let exp = expectationWithDescription("Bank Login Service Test");
		LoginHelper.login(auth) {
			let service = GetBankLoginFormService(auth: self.auth);
			service.execute(12288, completionHandler: { (result) in
				XCTAssert(result.code == .Success);
				
				exp.fulfill();
			});
		};
		
		waitForExpectationsWithTimeout(10, handler: nil);
    }
	
}
