//
//  AddManualBankService.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddManualBankService: BaseService {
	let postUrl = NSURL(string:"\(Config.getWebAPIURL())/account/save_account")!;
	let auth : AuthProtocol;
	let accountData : ManualLoanInfo;
	
	init(auth: AuthProtocol, accountsData: ManualLoanInfo) {
		self.auth = auth;
		self.accountData = accountsData;
	}
	
	func execute(completionHandler: (result: AddManualBankResult) -> Void) {
		let mutableURLRequest = self.getMutableRequest(self.postUrl, apiMethod: .POST, token: auth.getAuthenticatedUser()!.token);
		let jsonData = [
			"account": [
				"bank": self.accountData.accountName!,
				"loanType": self.accountData.loanType!,
				"apr": self.accountData.aprPercentageDouble,
				"minPayment": self.accountData.minimumPaymentDouble,
				"balance": self.accountData.balanceDouble,
				"paymentDueEveryMonth": self.accountData.paymentDueEachMonth!
			]
		];
		
		
		
		do {
			mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions())
		} catch {
			let result = AddManualBankResult();
			result.code = StatusCodes.Error;
			result.message = "Error parsing request JSON";
			completionHandler(result: result);
			return;
		}
		
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			switch response.result {
			case .Success:
				let json = JSON(response.result.value!);
				let result = AddManualBankResult();
				result.message = json["message"].stringValue;
				
				completionHandler(result: result);
			case .Failure:
				let result : AddManualBankResult = self.getResultFromErrorJSON(response);
				completionHandler(result: result);
			}
		}
	}
}
