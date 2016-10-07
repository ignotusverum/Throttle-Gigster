//
//  DeleteAccountService.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeleteAccountService: BaseService {

  let url = NSURL(string:"\(Config.getWebAPIURL())/accounts/")!;
//  let url = NSURL(string:"http://private-4166b-throttle2.apiary-mock.com/accounts/")!
  let auth : AuthProtocol;
  let account : UserAccountEntity;
  
  init(auth: AuthProtocol, account: UserAccountEntity) {
    self.auth = auth;
    self.account = account;
  }
  
  func execute(completionHandler: (success: Bool) -> Void) {
    let fullUrl = NSURL(string: "\(url)\(self.account.accountId)")!;
    print(fullUrl)
    /*
    var jsonData = [String: AnyObject]()
    if (self.account.createdManually == true) {
    jsonData = [ "account":[
      "bankId": self.account.bankId,
      "bank": self.account.userName,
      "accountName": self.account.accountName,
      "loanType": self.account.accountType,
      "apr": self.account.APRPercentage,
      "minPayment": self.account.minimumPayment,
      "balance": self.account.totalBalance,
      "paymentDueEveryMonth": self.account.dayOfMonthWhenDue
    ]];
    } else {
      print("Linked account")
    }
     */
    
    
    let mutableURLRequest = self.getMutableRequest(fullUrl, apiMethod: .DELETE, token: auth.getAuthenticatedUser()!.token);
    /*
    do {
      mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions())
    } catch {
      //      let result = AddManualBankResult();
      //      result.code = StatusCodes.Error;
      //      result.message = "Error parsing request JSON";
      //      completionHandler(result: result);
      return;
    }
    */
    
    self.afManager.request(mutableURLRequest).validate().responseJSON { response in
      print(response.result)
      switch response.result {
      case .Success:
        let json = JSON(response.result.value!);
        print(json)
        let message = json["message"].stringValue;
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
