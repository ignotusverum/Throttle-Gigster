//
//  NSError+Domains.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-23.
//  Copyright © 2015 Gigster. All rights reserved.
//

import Foundation

extension NSError {

    public convenience init(domain: String, code: Int, message: String) {
        
        let userInfo = [
        
            NSLocalizedDescriptionKey: message,
            NSLocalizedFailureReasonErrorKey: message
        ]
        
        self.init(domain: domain, code: code, userInfo: userInfo)
    }
}