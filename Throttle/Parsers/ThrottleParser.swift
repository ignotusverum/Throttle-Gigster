//
//  ThrottleParser.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-22.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit
import SwiftyJSON

class ThrottleParser: NSObject {

    struct ThrottleUserProfileKeys {
        
        static let id = "id"
        static let email = "email"
        static let created_at = "created_at"
        static let updated_at = "updated_at"
        static let name = "name"
        static let role = "role"
    }
    
    struct BankKeys {
        
        static let id = "id"
        static let name = "site_display_name"
        static let logo = "logo"
    }
    
    class func throttleUserFromJSON(json: JSON) -> ThrottleUser {
        
        let user = ThrottleUser()
        
        user.id = json[ThrottleUserProfileKeys.id].intValue
        user.email = json[ThrottleUserProfileKeys.email].string
        
        let created_at = json[ThrottleUserProfileKeys.created_at].string
        if nil != created_at {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            user.created_at = formatter.dateFromString(created_at!)
        }
        
        let updated_at = json[ThrottleUserProfileKeys.updated_at].string
        if nil != updated_at {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            user.updated_at = formatter.dateFromString(updated_at!)
        }
        
        user.name = json[ThrottleUserProfileKeys.name].string
        user.role = json[ThrottleUserProfileKeys.role].string
        
        return user
    }
    
    class func trottleBanksFromJSON(json: JSON) -> [Bank] {
    
        var banks = [Bank]()
		
		
        for bankObj in json["banks"].arrayValue {
            
            let bank = Bank()
            bank.id = bankObj[BankKeys.id].intValue
            bank.name = bankObj[BankKeys.name].stringValue
            bank.logoURLString = bankObj[BankKeys.logo].stringValue
            
            banks.append(bank)
        }
        
        return banks
    }
}
