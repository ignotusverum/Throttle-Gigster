//
//  RefreshAccountDataService.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class RefreshAllAccountDataService: BaseService {
	let url = NSURL(string:"\(Config.getWebAPIURL())/account/summary_all")!;
	let auth : AuthProtocol;
	
	let manualAccountRefreshUrl = NSURL(string:"\(Config.getWebAPIURL())/account/manual_accounts")!;
	
	init(auth: AuthProtocol) {
		self.auth = auth;
	}
	
	func execute(completionHandler: (result: RefreshAllAccountDataResult) -> Void) {
		let mutableURLRequest = self.getMutableRequest(url, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token);
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			let result = RefreshAllAccountDataResult();
			
			switch response.result {
			case .Success:
				let json = JSON(response.result.value!);
				
				guard let items = json["items"].array else {
					break;
				}
				
				for item in items {
					let type = item["type"].stringValue;
					var refreshAccountItemType : RefreshAllAccountDataResultItemType!;
					if type == "creditCard" {
						refreshAccountItemType = .Credit;
					}
					else if type == "loan" {
						refreshAccountItemType = .Loans;
					}
					else {
						refreshAccountItemType = .Bank;
					}
					
					let name = item["name"].stringValue;
					let id = item["id"].intValue;
					
					let refreshAccountItem = RefreshAllAccountDataResultItems(accountName: name, itemId: id, accountType: refreshAccountItemType);
					
					if let balance = item["balance"]["amount"].double {
						refreshAccountItem.balance = balance;
					}
					
					if let interestRate = item["interestRate"].double {
						refreshAccountItem.interestRate = interestRate;
					}
          
          if let apr = item["apr"].double {
            refreshAccountItem.interestRate = apr;
          }
					
					if let minimumBalance = item["minimumAmountDue"]["amount"].double {
						refreshAccountItem.minimumAmountDue = minimumBalance;
					}
          
          if let stringDate = item["dueDate"].string {
            refreshAccountItem.dayOfWeekDue = stringDate;
          }
          
          if let hasInterestRate = item["has_interest_rate"].bool {
            refreshAccountItem.hasAPR = hasInterestRate;
          }
          
          if let hasPaymentDueDate = item["has_duedate"].bool {
            refreshAccountItem.hasPaymentDueDate = hasPaymentDueDate;
          }
          
          if let hasAPR = item["has_apr"].bool {
            refreshAccountItem.hasAPR = hasAPR;
          }
          
          refreshAccountItem.lastDataRefreshDate = NSDate()
					
					refreshAccountItem.containerType = item["type"].string;
					refreshAccountItem.bankId = item["bank_id"].intValue;
					
					switch (refreshAccountItem.accountType) {
					case .Credit:
						result.credits.append(refreshAccountItem);
						break;
					case .Loans:
						result.loans.append(refreshAccountItem);
						break;
					case .Bank:
						result.banks.append(refreshAccountItem);
						break;
					}
				}
				
				print(json);
				break;
			default:
				result.code = .Error;
				let json = self.getResultFromErrorJSON(response);
				print("\(json)");
				
				break;
			}
			
			self.downloadManualAccounts(result, completionBlock:{
				completionHandler(result:result);
			});
      
		  let notificationService = NotificationsService(auth:ConfigFactory.getAuth())
		  notificationService.clearAndRegisterAllNotifications()
		};
	}
	
	private func downloadManualAccounts(result:RefreshAllAccountDataResult, completionBlock: () -> Void) {
		let mutableURLRequest = self.getMutableRequest(manualAccountRefreshUrl, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token);
		
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			switch response.result {
			case .Success:
				let json = JSON(response.result.value!);
				
				if let items = json["manual_accounts"].array {
					for item in items {
						
						let refreshAccountItem = RefreshAllAccountDataResultItems(accountName: item["bank"].stringValue, itemId: item["id"].intValue, accountType: .Loans);
						if let balance = item["balance"].double {
							refreshAccountItem.balance = balance;
						}
						
						if let minPayment = item["minPayment"].double {
							refreshAccountItem.minimumAmountDue = minPayment;
						}
						
						if let apr = item["apr"].double {
							refreshAccountItem.interestRate = apr;
						}
						
						if let paymentDueEveryMonth = item["paymentDueEveryMonth"].string {
							refreshAccountItem.dayOfWeekDue = paymentDueEveryMonth;
						}
            
            refreshAccountItem.lastDataRefreshDate = NSDate()
						
						refreshAccountItem.manualAccount = true;
						result.loans.append(refreshAccountItem);
						print(item);
					}
				}
				
				break;
			default:
				break;
			}
			
			completionBlock();
		};
	}
}
