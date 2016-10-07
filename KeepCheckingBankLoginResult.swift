//
//  KeepCheckingBankLoginResult.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class KeepCheckingBankLoginResult: BaseResult {
	var accountId : Int?;
	var bankRequiresSecurityQuestions = false;
	var bankSecurityQuestions : [String]?;
}
