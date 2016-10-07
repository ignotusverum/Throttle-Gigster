//
//  FetchMonthlyPaymentService.swift
//  Throttle
//
//  Created by Jeff Sult on 9/9/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import SwiftyJSON

class GetMonthlyPaymentService: BaseService {
    let url = NSURL(string:"\(Config.getWebAPIURL())/users/get_payment_preference")!
    let auth: AuthProtocol
    
    init(auth: AuthProtocol) {
        self.auth = auth
    }
    
    func execute(completionHandler: (result: Int?) -> Void) {
        let mutableURLRequest = self.getMutableRequest(url, apiMethod: .GET, token: auth.getAuthenticatedUser()!.token)
        
        self.afManager.request(mutableURLRequest).validate().responseJSON { response in
            switch response.result {
            case .Success:
                let json = JSON(response.result.value!)
                if let paymentPreferenceString = json["payment_preference"].string {
                    completionHandler(result: Int(paymentPreferenceString))
                } else {
                    completionHandler(result: nil)
                }
            default:
                completionHandler(result: nil)
                break
            }
        }
    }
}