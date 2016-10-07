//
//  GetAccountDetailsService.swift
//  Throttle
//
//  Created by Marco Ledesma on 5/31/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetAccountDetailsService: BaseService {
	let auth : AuthProtocol;
	
	init(auth: AuthProtocol) {
		self.auth = auth;
	}
	
	func execute(itemId: Int, itemType: String, completionBlock: (interest: Double) -> Void) {
		let url = NSURL(string:"\(Config.getWebAPIURL())/account/summary?item_id=\(itemId)&container=\(itemType)")!;
		let mutableURLRequest = self.getMutableRequest(url, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token);
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			var interestRate = 0.0;
			
			switch response.result {
				
			case .Success:
				let json = JSON(response.result.value!);
				
				if let items = json["items"].array where items.count > 0 {
					let item = items[0];
					
					if let interest = item["apr"].double {
						interestRate = interest;
					}
				}
				
				break;
			default:
				
				print("Error retrieving APR details of account.");
				print(response);
				
				break;
			}
			
			completionBlock(interest: interestRate);
		};
	}
}
