//
//  CheckBankLoginServiceTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
@testable import Throttle

class CheckBankLoginServiceTest: XCTestCase {
	let auth = MockedAuth();
	var keepCheckingBankLoginService : LogIntoBankAndKeepCheckingBankLoginService!;
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testBankRefresh_getSuccessResult() {
		let expectations = expectationWithDescription("checkBankLogin");
		
		//log user in
		LoginHelper.login(auth) {
			
			//this executes the user login until its successful or it requires security questions
			self.keepCheckingBankLoginService = LogIntoBankAndKeepCheckingBankLoginService(
				un: self.auth.testBankUsername,
				pw: self.auth.testBankPassword,
				bId: self.auth.testBankId,
				auth: self.auth,
				completionBlock: { (result) -> Void in
					XCTAssert(result.code == .Success);
					
					//if it requires security questions, send the answers
					if (result.bankRequiresSecurityQuestions) {
						XCTAssert(result.bankSecurityQuestions?.count > 0);
						print(result.bankSecurityQuestions);
						self.keepCheckingBankLoginService.sendSecurityQuestionAnswers(result.accountId!, answers: ["karnataka", "Saint Paul HR SEC School"], completionBlock: nil);
					}
					else {
						expectations.fulfill();
					}
			});
			
			self.keepCheckingBankLoginService.execute();
		}
		
		waitForExpectationsWithTimeout(50, handler: nil);
	}
	
}
