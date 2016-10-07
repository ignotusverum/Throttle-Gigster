//
//  RefreshAllAccountDataServiceTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//
import XCTest
@testable import Throttle

class RefreshAllAccountDataServiceTest: XCTestCase {
	let auth = MockedAuth();

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testRefresh_getSuccessResult() {
		let exp = expectationWithDescription("refreshing account data");
		LoginHelper.login(auth) {
			let service = RefreshAllAccountDataService(auth: self.auth);
			service.execute { (result) -> Void in
				XCTAssert(result.code == .Success);
				exp.fulfill();
			};
		};
		
		waitForExpectationsWithTimeout(10, handler: nil);
	}
}
