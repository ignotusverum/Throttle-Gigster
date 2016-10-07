//
//  UpdateAccountService.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdateAccountService: BaseService {
  let url = NSURL(string:"\(Config.getWebAPIURL())/account_information/")!;

  let auth : AuthProtocol;
  let account : UserAccountEntity;
  
  init(auth: AuthProtocol, account: UserAccountEntity) {
    self.auth = auth;
    self.account = account;
  }
  
  func execute(completionHandler: (success: Bool) -> Void) {
    let mutableURLRequest = self.getMutableRequest(url, apiMethod: .PUT, token: auth.getAuthenticatedUser()!.token);
    var jsonData:[String: AnyObject] = [
        "bankId": self.account.bankId,
        "bank": self.account.accountName,
        "loanType": self.account.accountType,
        "apr": self.account.APRPercentage,
        "interest_rate": self.account.APRPercentage,
        "minPayment": self.account.minimumPayment,
        "balance": self.account.totalBalance,
    ];
    
    if self.account.createdManually {
      jsonData["id"] = self.account.accountId
      jsonData["paymentDueEveryMonth"] = self.account.dayOfMonthWhenDue
    } else {
      jsonData["item_id"] = self.account.accountId
      jsonData["due_date"] = self.account.dayOfMonthWhenDue
    }
    
    do {
      mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions())
    } catch {
      return;
    }
    
    self.afManager.request(mutableURLRequest).validate().responseJSON { response in
      print(response.result)
      switch response.result {
      case .Success:
        let json = JSON(response.result.value!);
        print(json)
//        let message = json["message"].stringValue;
//        let result = AddManualBankResult();
//        result.message = json["message"].stringValue;
        
        completionHandler(success: true);
      case .Failure:
        print("fail")
//        let result : AddManualBankResult = self.getResultFromErrorJSON(response);
        completionHandler(success: false);
      }
    }
  }
    
}
