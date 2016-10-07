//
//  UpdateMonthlyPaymentService.swift
//  Throttle
//
//  Created by Jeff Sult on 9/9/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import SwiftyJSON

class UpdateMonthlyPaymentService: BaseService {
    let url = NSURL(string:"\(Config.getWebAPIURL())/users/update_payment_preference")!
    let auth: AuthProtocol
    
    init(auth: AuthProtocol) {
        self.auth = auth
    }
    
    func execute(newValue: Int, completionHandler: (success: Bool) -> Void) {
        let mutableURLRequest = self.getMutableRequest(url, apiMethod: .POST, token: auth.getAuthenticatedUser()!.token)
        
        let requestBodyDetails = [
            "payment_preference": newValue
        ]
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDetails, options: NSJSONWritingOptions())
        } catch {
            completionHandler(success: false)
            return
        }
        
        self.afManager.request(mutableURLRequest).validate().responseJSON { response in
            switch response.result {
            case .Success:
                completionHandler(success: true)
            default:
                completionHandler(success: false)
                break
            }
        }
    }
}