//
//  GetBankLoginFormService.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/1/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetBankLoginFormService: BaseService {
	let url = "\(Config.getWebAPIURL())/banks/";
	let auth : AuthProtocol;
	
	init(auth: AuthProtocol) {
		self.auth = auth;
	}
	
	func execute(bankId: Int, completionHandler: (result: GetBankLoginFormResult) -> Void) {
		let fullUrl = NSURL(string: "\(url)\(bankId)")!;
		let mutableURLRequest = self.getMutableRequest(fullUrl, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token);
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			let result = GetBankLoginFormResult();
			
			
			
			switch response.result {
			case .Success:
				let json = JSON(response.result.value!);
				result.bankLogo = json["logo"].string;
				
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
