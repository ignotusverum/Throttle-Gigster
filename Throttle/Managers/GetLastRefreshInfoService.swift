//
//  GetLastRefreshInfoService.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetLastRefreshInfoService: BaseService {
	let url = "\(Config.getWebAPIURL())/account/get_last_refresh_info?id=";
	let auth : AuthProtocol;
	let accountId : Int;
	
	init(auth: AuthProtocol, accountId: Int) {
		self.auth = auth;
		self.accountId = accountId;
	}
	
	func execute(completionHandler: (result: GetLastRefreshInfoResult) -> Void) {
		let refreshUrl = NSURL(string:"\(url)\(accountId)")!;
		let mutableURLRequest = self.getMutableRequest(refreshUrl, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token);
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			var result = GetLastRefreshInfoResult();
			
			switch response.result {
			case .Success:
				let json = JSON(response.result.value!);
				result = self.getResultFromJson(json);
				
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

	
	private func getResultFromJson(json: JSON) -> GetLastRefreshInfoResult {
		let result = GetLastRefreshInfoResult();
		
		if let account = json["account"].dictionary {
			result.accountId = account["id"]?.intValue;
			result.accountUserId = account["user_id"]?.intValue;
			result.accountBankId = account["bank_id"]?.intValue;
			result.accountYodleeId = account["yodlee_id"]?.intValue;
			result.accountStatusCode = account["status_code"]?.intValue;
			result.accountLastRefresh = account["last_refresh"]?.intValue;
		}
		else {
			result.code = StatusCodes.Error;
			result.message = "Unable to parse account dictionary";
		}
		
		
		return result;
	}

}
