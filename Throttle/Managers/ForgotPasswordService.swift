//
//  ResetPasswordService.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class ForgotPasswordService: BaseService {
	let postUrl = NSURL(string:"\(Config.getWebAPIURL())/users/password")!;
	let email: String;
	
	init(email: String) {
		self.email = email;
	}
	
	func execute(completionBlock: (success: Bool) -> Void) {
		var success = true;
		
		let mutableURLRequest = self.getMutableRequest(self.postUrl, apiMethod: .POST, token: nil);
		let requestBodyDetails = [
			"user": [
				"email":self.email
			]
		];
		
		do {
			mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDetails, options: NSJSONWritingOptions())
		} catch {
			success = false;
			completionBlock(success: success);
			return;
		}
		
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			switch response.result {
			case .Failure:
				success = false;
			default:
				break;
			}
			
			completionBlock(success: success);
		}
	}
}
