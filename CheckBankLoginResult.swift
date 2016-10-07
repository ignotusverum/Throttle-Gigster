//
//  CheckBankLoginResult.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/23/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class CheckBankLoginResult: BaseResult {
	var isRefreshing: Bool?;
	var requiresSecurityQuestions = false;
	var securityQuestions : [String] = [];
}
