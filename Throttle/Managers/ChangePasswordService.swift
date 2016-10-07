//
//  ChangePasswordService.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 2/29/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChangePasswordService: BaseService {
  let requestChangePasswordUrl = NSURL(string:"\(Config.getWebAPIURL())/users/password")!;
//  let url = NSURL(string:"http://private-4166b-throttle2.apiary-mock.com/users/password")!;
  let auth : AuthProtocol;
  
  init(auth: AuthProtocol) {
    self.auth = auth;
  }
  
  func execute(email:String, completionHandler: (success:Bool) -> Void) {
    
    let mutableURLRequest = self.getMutableRequest(self.requestChangePasswordUrl, apiMethod: .POST, token: self.auth.getAuthenticatedUser()!.token);
    
    let requestBodyDetails = [
      "user": [
        "email": email,
      ]
    ];

    do {
      mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDetails, options: NSJSONWritingOptions())
    } catch {
      completionHandler(success: false);
      return;
    }
    print(mutableURLRequest)
    
    self.afManager.request(mutableURLRequest).validate().responseJSON { response in
 
      switch response.result {
      case .Success:
        completionHandler(success: true);
        break;
      default:
        completionHandler(success: false);
        break;
      }
    }
  }
  
  
  
  /*
   
   func execute(currentPassword:String, newPassword:String, confirmPassword:String, completionHandler: (success:Bool) -> Void) {
   
   let mutableURLRequest = self.getMutableRequest(self.requestChangePasswordUrl, apiMethod: .POST, token: self.auth.getAuthenticatedUser()!.token);
   
   let requestBodyDetails = [
   "user": [
   "current_password": currentPassword,
   "password": newPassword,
   "password_confirmation": confirmPassword
   ]
   ];
   
   do {
   mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDetails, options: NSJSONWritingOptions())
   } catch {
   completionHandler(success: false);
   return;
   }
   
   self.afManager.request(mutableURLRequest).validate().responseJSON { response in
   let json = JSON(response.data!)
   print(json)
   switch response.result {
   case .Success:
   completionHandler(success: true);
   break;
   default:
   completionHandler(success: false);
   break;
   }
   }
   }
 */
}
