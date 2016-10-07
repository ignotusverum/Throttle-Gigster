//
//  LoginIntoBankService.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/18/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginIntoBankService: BaseService {
	let postUrl = NSURL(string:"\(Config.getWebAPIURL())/accounts")!;
	let username: String;
	let password: String;
	let bankId: Int;
	let auth : AuthProtocol;
	
	init(un: String, pw: String, bankId: Int, auth: AuthProtocol) {
		self.username = un;
		self.password = pw;
		self.auth = auth;
		self.bankId = bankId;
	}
	
	func execute(completionBlock: (result: LoginIntoBankResult) -> Void) {
		let mutableURLRequest = self.getMutableRequest(self.postUrl, apiMethod: .POST, token: auth.getAuthenticatedUser()!.token);
		let jsonData = [
			"provider_id": self.bankId,
			"provider_information": [
					"login": self.username,
					"password": self.password
				]
		];
		
		
		
		do {
			mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions())
		} catch {
			let result = LoginIntoBankResult();
			result.code = StatusCodes.Error;
			result.message = "Error parsing request JSON";
			completionBlock(result: result);
			return;
		}
		
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			switch response.result {
			case .Success:
				let json = JSON(response.result.value!);
				let result = LoginIntoBankResult();
				result.message = json["message"].stringValue;
				
				if let account = json["account"].dictionary {
					result.accountId = account["id"]?.intValue;
				}
				else {
					result.code = StatusCodes.Error;
					result.message = "Unable to parse account data";
				}
				
				completionBlock(result: result);
			case .Failure:
				let result : LoginIntoBankResult = self.getResultFromErrorJSON(response);
				completionBlock(result: result);
			}
		}
	}
}
