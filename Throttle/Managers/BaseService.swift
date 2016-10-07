//
//  BaseService.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/24/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import Alamofire;
import SwiftyJSON;

enum BaseServiceAPIMethod : String
{
	case POST = "POST"
	case GET = "GET"
	case DELETE = "DELETE"
	case PUT = "PUT"
}

class BaseService: NSObject {
	var afManager = Alamofire.Manager.sharedInstance;
	
	
	func getMutableRequest(url: NSURL, apiMethod: BaseServiceAPIMethod, token: String? = nil) -> NSMutableURLRequest
	{
		self.afManager.session.configuration.timeoutIntervalForRequest = 100;
		self.afManager.session.configuration.timeoutIntervalForResource = 100;
	
		let mutableURLRequest = NSMutableURLRequest(URL: url);
		mutableURLRequest.HTTPMethod = apiMethod.rawValue;
		mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type");
		mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept");
		
		if let t = token {
			mutableURLRequest.setValue(t, forHTTPHeaderField: "Authorization");
		}
		
		return mutableURLRequest;
	}
	
	func getResultFromErrorJSON<T : BaseResult>(response: Response<AnyObject, NSError>) -> T {
		let json = JSON(data: response.data!)
		let result = T();
		let joiner = ", "
		var errors: [String] = []
		for result in json["errors"].arrayValue {
			if let error = result["error"].string {
				errors.append(error)
			}
		}
		
		let message = errors.joinWithSeparator(joiner)
		let error = NSError(domain: "Throttle.Comms", code: response.result.error!.code, message: message)
		result.code = StatusCodes.Error;
		
		if let r = response.response {
			if (r.statusCode == 401) {
				result.code = .Unauthorized;
			}
		}
		
		result.message = "\(error)";
		
		print("Error logging into bank: \(error). JSON: \(json)");
		
		return result;
	}
}
