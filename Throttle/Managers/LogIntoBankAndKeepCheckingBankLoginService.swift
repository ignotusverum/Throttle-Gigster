//
//  KeepCheckingBankLoginService.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class LogIntoBankAndKeepCheckingBankLoginService: BaseService {
	private let username: String;
	private let password: String;
	private let bankId: Int;
	private let auth : AuthProtocol;
	private var completionBlock : (result: KeepCheckingBankLoginResult) -> Void;
	private var timer : NSTimer!;
	private var apiCallInProgress = false;
	private var logIntoBankResult : LoginIntoBankResult?;
	private var numberOfTries = -1;
	let MAX_NUMBER_OF_TRIES = 90;
	
	init(un: String, pw: String, bId: Int, auth: AuthProtocol, completionBlock: (result: KeepCheckingBankLoginResult) -> Void) {
		self.username = un;
		self.password = pw;
		self.bankId = bId;
		self.auth = auth;
		self.completionBlock = completionBlock;
		self.numberOfTries = MAX_NUMBER_OF_TRIES;
	}
	
	func execute() {
		let service = LoginIntoBankService(un: self.username, pw: self.password, bankId: self.bankId, auth: self.auth);
		service.execute { (result) -> Void in
			if (result.code == StatusCodes.Success) {
				self.logIntoBankResult = result;
				self.startRefresh();
			}
			else {
				self.processErrorResult("Error logging into bank");
			}
		};
	}
	
	
	func sendSecurityQuestionAnswers(accountId: Int, answers: [String], completionBlock: ((result: KeepCheckingBankLoginResult) -> Void)?) {
		
		if let block = completionBlock {
			self.completionBlock = block;
		}
		
		let service = SendSecurityQuestionAnswersService(accountId: accountId, auth: self.auth, answers: answers);
		service.execute { (result) in
			if (result.code == .Success) {
				self.startRefresh();
			}
			else {
				self.processErrorResult("Error sending security questions");
			}
		};
	}
	
	func startRefresh() {
		if (self.timer != nil) {
			self.timer.invalidate();
			self.timer = nil;
		}
		
		self.numberOfTries = MAX_NUMBER_OF_TRIES;
		self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(LogIntoBankAndKeepCheckingBankLoginService.checkBankLogin), userInfo: nil, repeats: true);
	}
	
	
	func checkBankLogin() {
		if (self.numberOfTries <= 0)
		{
			self.processErrorResult("Timeout");
			return;
		}
		
		if (apiCallInProgress == false) {
			apiCallInProgress = true;
		} else { return; }
		
		if let loginBankResult = logIntoBankResult
			where loginBankResult.accountId != nil {
			
			let service = CheckBankLoginService(auth: self.auth, accountId: loginBankResult.accountId!);
			service.execute({ (result) -> Void in
				if (result.code == .Success) {
					if result.isRefreshing == false {
						self.timer.invalidate();
						self.timer = nil;
						
						let keepLoginIntoBankResult = KeepCheckingBankLoginResult();
						keepLoginIntoBankResult.accountId = loginBankResult.accountId!;
						
						self.completionBlock(result: keepLoginIntoBankResult);
					}
					else if (result.requiresSecurityQuestions) {
						self.timer.invalidate();
						self.timer = nil;
						
						let keepLoginIntoBankResult = KeepCheckingBankLoginResult();
						keepLoginIntoBankResult.accountId = loginBankResult.accountId!;
						keepLoginIntoBankResult.bankRequiresSecurityQuestions = true;
						keepLoginIntoBankResult.bankSecurityQuestions = result.securityQuestions;
						
						self.completionBlock(result: keepLoginIntoBankResult);
						self.apiCallInProgress = false;
					}
					else {
						self.apiCallInProgress = false;
						self.numberOfTries = self.numberOfTries - 1;
					}
				}
				else {
					self.processErrorResult("API Error");
				}
			});
			return;
		}

		
		self.processErrorResult("Unknown error happened.");
	}
	
	private func processErrorResult(message: String?) {
		let result = KeepCheckingBankLoginResult();
		result.code = StatusCodes.Error;
		result.message = message;
		completionBlock(result: result);
		
		if (self.timer != nil) {
			self.timer.invalidate();
			self.timer = nil;
		}
	}
}
