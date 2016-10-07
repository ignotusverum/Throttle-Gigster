//
//  SendSecurityQuestionAnswersService.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class SendSecurityQuestionAnswersService: BaseService {
	let putUrl : NSURL;
	let auth : AuthProtocol;
	let accountId: Int;
	let answers : [String];
	
	init(accountId: Int, auth: AuthProtocol, answers: [String]) {
		self.accountId = accountId;
		self.auth = auth;
		self.answers = answers;
		
		self.putUrl = NSURL(string: "\(Config.getWebAPIURL())/accounts/\(accountId))")!;
	}
	
	func execute(completionHandler: (result: SendBankSecurityQuestionResult) -> Void) {
		let mutableURLRequest = self.getMutableRequest(putUrl, apiMethod: .PUT, token: auth.getAuthenticatedUser()!.token);
		let jsonData = [
			"answers": self.answers
		];
		
		do {
			mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions())
		} catch {
			let result = SendBankSecurityQuestionResult();
			result.code = StatusCodes.Error;
			result.message = "Error parsing request JSON";
			completionHandler(result: result);
			return;
		}
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			let result = SendBankSecurityQuestionResult();
			
			switch response.result {
			case .Success:
				
				break;
			default:
				result.code = .Error;
				let json = self.getResultFromErrorJSON(response);
				print("\(json)");
				
				break;
			}
			
			completionHandler(result:result);
		};
	}
}
