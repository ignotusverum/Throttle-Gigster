//
//  ChangeEmailService.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/29/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChangeEmailService: BaseService {
  
  
  
  let requestChangeEmailUrl = NSURL(string:"\(Config.getWebAPIURL())/users/change_email")!;
  let url = NSURL(string:"http://private-4166b-throttle2.apiary-mock.com/users/change_email")!;
  let auth : AuthProtocol;
  
  init(auth: AuthProtocol) {
    self.auth = auth;
  }
  
  func execute(email:String, completionHandler: (success:Bool) -> Void) {
    let mutableURLRequest = self.getMutableRequest(self.requestChangeEmailUrl, apiMethod: .POST, token: self.auth.getAuthenticatedUser()!.token);
    
    let requestBodyDetails = [
      "user": [
        "email":email
      ]
    ];
    
    do {
      mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDetails, options: NSJSONWritingOptions())
    } catch {
      completionHandler(success: false);
      return;
    }
    
    self.afManager.request(mutableURLRequest).validate().responseJSON { response in
      switch response.result {
      case .Success:
        let json = JSON(response.result.value!);
        let message = json["message"].stringValue
        print(message)
        completionHandler(success: true);
        break;
      default:
        completionHandler(success: false);
        break;
      }
    }
  }
}
