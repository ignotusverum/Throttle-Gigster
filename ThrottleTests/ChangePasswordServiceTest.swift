//
//  ChangePasswordServiceTest.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/26/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
@testable import Throttle

class ChangePasswordServiceTest: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testChangeEmail_getSuccessResult() {
    let expectations = expectationWithDescription("changePassword");
    
    let auth = MockedAuth();
    LoginHelper.login(auth, completionBlock: {
      let service = ChangePasswordService(auth: auth)
      service.execute(auth.debugUsername, completionHandler:  { (success) -> Void in
        XCTAssert(success == true);
        expectations.fulfill();
      });
    })
    waitForExpectationsWithTimeout(10, handler: nil);
  }
}
