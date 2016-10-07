//
//  AppData.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2016-01-02.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class AppData: NSObject {

    static let sharedAppData = AppData()


    
    enum PlanKeys: Int {
        
        case Interest = 0
        case Balance = 1
        case Total = 2
        case Payment = 3
    }
    
    static let planKeysNames: Dictionary<PlanKeys,String> = [.Interest:"Total interest across accounts",
        .Balance:"Total balance across accounts payments",
        .Total:"Grand total across accounts",
        .Payment:"Total of all monthly min payments"]
    
    var planData: Dictionary<String,String> = [planKeysNames[.Interest]!:"$21.000",
        planKeysNames[.Balance]!:"$115.000",
        planKeysNames[.Total]!:"$136.000",
        planKeysNames[.Payment]!:"$115.000"]
}
