//
//  BaseResult.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/24/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

enum StatusCodes : Int {
	case Success = 200
	case InvalidRequest = 400
	case NotFound = 404
	case Unauthorized = 401
	case Error = 500
	case NoInternetConnection = 999
	case Timeout = 600
}


class BaseResult: NSObject {
	var code : StatusCodes!;
	var message : String?;
	
	required override init () {
		super.init();
		self.code = StatusCodes.Success;
	}
}