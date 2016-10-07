//
//  CheckBankLoginService.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckBankLoginService: BaseService {
	let url = "\(Config.getWebAPIURL())/account/refresh?id=";
	let auth : AuthProtocol;
	let accountId : Int;
	
	init(auth: AuthProtocol, accountId: Int) {
		self.auth = auth;
		self.accountId = accountId;
	}
	
	func execute(completionHandler: (result: CheckBankLoginResult) -> Void) {
		let refreshUrl = NSURL(string:"\(url)\(accountId)")!;
		let mutableURLRequest = self.getMutableRequest(refreshUrl, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token);
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			let result = CheckBankLoginResult();
			
			switch response.result {
			case .Success:
				var json = JSON(response.result.value!);
				
				let refreshStatus = json["refreshStatus"].string;
				let refreshStatusMessage = json["refreshStatusMessage"].string;
				result.isRefreshing = refreshStatus != "SUCCESS";
				
				if (refreshStatus == "LOGIN_FAILURE" || refreshStatusMessage == "LOGIN_FAILED") {
					result.code = .Unauthorized;
					let json = self.getResultFromErrorJSON(response);
					print(json);
					break;
				}
				
				if (refreshStatus == "REFRESH_CANCELLED") {
					result.code = .Timeout;
					break;
				}
				
				if let loginForm = json["loginForm"].dictionary {
					result.requiresSecurityQuestions = true;
					if let questions = loginForm["row"]?.array {
						for q in questions {
							result.securityQuestions.append(q["label"].stringValue);
						}
					}
				}
				
				break;
			default:
				result.code = .Error;
				
				if let data = response.data {
					let json = JSON(data);
					let refreshStatus = json["refreshStatus"].string;
					let refreshStatusMessage = json["refreshStatusMessage"].string;
					
					if (refreshStatus == "LOGIN_FAILURE" || refreshStatusMessage == "LOGIN_FAILED") {
						result.code = .Unauthorized;
					}
				}
				else {
					let json = self.getResultFromErrorJSON(response);
					print(json);
				}
				
				break;
			}
			
			completionHandler(result:result);
		};
	}

}
