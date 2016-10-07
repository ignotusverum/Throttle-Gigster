//
//  ThrottleCommunicationsManager.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-21.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


//should be refactored. will do this later - marco
class ThrottleCommunicationsManager: NSObject {

    // singlton
    static let defaultManager = ThrottleCommunicationsManager()
    
    // netowkring manager
    private let afManager = Alamofire.Manager.sharedInstance
    
    struct ThrottleSignUpConfig {
        static let url = "\(Config.getWebAPIURL())/users"
        static let method = "POST"
        static let headers = ["Content-Type":"application/json", "Accept":"application/json"]
    }
    
    struct ThrottleSignInConfig {
		static let url = "\(Config.getWebAPIURL())/users/sign_in"
        static let method = "POST"
        static let headers = ["Content-Type":"application/json", "Accept":"application/json"]
    }
    
    struct ThrottleBanksSearchConfig {
		static let url = "\(Config.getWebAPIURL())/banks?search="
        static let method = "GET"
        static let headers = ["Content-Type":"application/json", "Accept":"application/json"]
    }
    
    struct ThrottlePopularBanksConfig {
		static let url = "\(Config.getWebAPIURL())/banks"
        static let method = "GET"
        static let headers = ["Content-Type":"application/json", "Accept":"application/json"]
    }
	
	
	
    func signUp(email: String, password: String, completionHandler: (ThrottleUser?, NSError?) -> Void)
    {
        let URL = NSURL(string: ThrottleSignUpConfig.url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = ThrottleSignUpConfig.method
        
        let parametersDict = ["email":email, "password":password]
        let bodyDict = ["user":parametersDict]
        
        // transform params into a JSON body
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: NSJSONWritingOptions())
        } catch {
            // No-op
        }
        
        // add all custom headers
        for key in ThrottleSignUpConfig.headers.keys {
            mutableURLRequest.setValue(ThrottleSignUpConfig.headers[key], forHTTPHeaderField: key)
        }
        
        self.afManager.request(mutableURLRequest).validate().responseJSON { (response) in
            
            switch response.result {
                
            case .Success:
				//let headers = response.response?.allHeaderFields;
				//let setCookie = headers!["Set-Cookie"] as! String;
				//Auth.setUserKey(setCookie);
				
                let json = JSON(response.result.value!)
                if json["errors"].isExists() {
                  let joiner = ", "
                  let errors = json["errors"].dictionaryValue
                  var messages: [String] = []
                  for key in errors {
                    messages.append(key.0 + " " + key.1.arrayValue[0].stringValue)
                  }
                  
                  let message = messages.joinWithSeparator(joiner)
                  let error = NSError(domain: "Throttle.Comms", code: json["response"]["code"].intValue, message: message)
                  // Handles network timeouts, no connectivity, errors, and all fail cases.
                  completionHandler(nil, error)
                  return
                }
                let user = ThrottleParser.throttleUserFromJSON(json)
                completionHandler(user, nil)
                
            case .Failure:
                
                // ex. "{"errors":[{"error":"Invalid email or password."}, {"error":"password is too short."}]}"
                let json = JSON(data: response.data!)
                
                let joiner = ", "
                var errors: [String] = []
                for result in json["errors"].arrayValue {
                    if let error = result["error"].string {
                        errors.append(error)
                    }
                }
                
                let message = errors.joinWithSeparator(joiner)
                let error = NSError(domain: "Throttle.Comms", code: response.result.error!.code, message: message)
                // Handles network timeouts, no connectivity, errors, and all fail cases.
                completionHandler(nil, error)
            }
        }
    }
    
	func signIn(email: String, password: String, auth:AuthProtocol, completionHandler: (ThrottleUser?, NSError?) -> Void)
    {
        let URL = NSURL(string: ThrottleSignInConfig.url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = ThrottleSignInConfig.method
        
        let parametersDict = ["email":email, "password":password]
        let bodyDict = ["user":parametersDict]
        
        // transform params into a JSON body
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: NSJSONWritingOptions())
        } catch {
            // No-op
        }
        
        // add all custom headers
        for key in ThrottleSignInConfig.headers.keys {
            mutableURLRequest.setValue(ThrottleSignInConfig.headers[key], forHTTPHeaderField: key)
        }
        
        self.afManager.request(mutableURLRequest).validate().responseJSON { response in
            switch response.result {
            case .Success:
				do {
					let json = JSON(response.result.value!)
					let user = ThrottleParser.throttleUserFromJSON(json)

					if let token = json["token"].string {
						let authenticatedUser = AuthenticatedUser(password: password, token: token);
						let success = auth.setAuthenticatedUser(authenticatedUser);

						if (success) {
							completionHandler(user, nil);
						}
						else {
							completionHandler(nil, NSError(domain: "Throttle.Comms", code: 0, message: "Error saving user key"));
						}
					} else {
						throw Error.errorWithCode(1, failureReason:"No cookie value found. The user did not verify their account");
					}
				}
				catch {
					let error = NSError(domain: "Throttle.Comms", code: 0, message: "No cookie value found. The user did not verify their account")
					completionHandler(nil, error)
				}
            case .Failure:
                // ex. "{"errors":[{"error":"Invalid email or password."}, {"error":"password is too short."}]}"
                let json = JSON(data: response.data!)

                let joiner = ", "
                var errors: [String] = []
                for result in json["errors"].arrayValue {
                    if let error = result["error"].string {
                        errors.append(error)
                    }
                }
                
                let message = errors.joinWithSeparator(joiner)
                let error = NSError(domain: "Throttle.Comms", code: response.result.error!.code, message: message)
                // Handles network timeouts, no connectivity, errors, and all fail cases.
                completionHandler(nil, error)
            }
        }
    }
    
    func fetchPopularBanks(completionHandler: ([Bank]?, NSError?) -> Void)
    {
        let URL = NSURL(string: ThrottlePopularBanksConfig.url)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = ThrottlePopularBanksConfig.method
        
        // add all custom headers
        for key in ThrottlePopularBanksConfig.headers.keys {
            mutableURLRequest.setValue(ThrottlePopularBanksConfig.headers[key],
				forHTTPHeaderField: key)
        }
		
		let auth = ConfigFactory.getAuth();
		mutableURLRequest.setValue(auth.getAuthenticatedUser()!.token, forHTTPHeaderField: "Authorization");

        
        self.afManager.request(mutableURLRequest).validate().responseJSON { response in
            switch response.result {
            case .Success:
                
                let json = JSON(response.result.value!)
                let banks = ThrottleParser.trottleBanksFromJSON(json)
                completionHandler(banks, nil)
                
            case .Failure:
                
                // ex. "{"errors":[{"error":"Invalid email or password."}, {"error":"password is too short."}]}"
                let json = JSON(data: response.data!)
                
                let joiner = ", "
                var errors: [String] = []
                for result in json["errors"].arrayValue {
                    if let error = result["error"].string {
                        errors.append(error)
                    }
                }
                
                let message = errors.joinWithSeparator(joiner)
                let error = NSError(domain: "Throttle.Comms", code: response.result.error!.code, message: message)
                // Handles network timeouts, no connectivity, errors, and all fail cases.
                completionHandler(nil, error)
            }
        }
    }
    
    func fetchBanksWithName(name: String, completionHandler: ([Bank]?, NSError?) -> Void)
    {
		let escapedParams = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let URL = NSURL(string: ThrottleBanksSearchConfig.url + escapedParams!)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
		mutableURLRequest.HTTPMethod = ThrottleBanksSearchConfig.method;
		
        // add all custom headers
        for key in ThrottleBanksSearchConfig.headers.keys {
            mutableURLRequest.setValue(ThrottleBanksSearchConfig.headers[key], forHTTPHeaderField: key)
        }
		
		let auth = ConfigFactory.getAuth();
		mutableURLRequest.setValue(auth.getAuthenticatedUser()!.token, forHTTPHeaderField: "Authorization");
		
		
        self.afManager.request(mutableURLRequest).validate().responseJSON { response in
            switch response.result {
                
            case .Success:
                
                let json = JSON(response.result.value!)
                let banks = ThrottleParser.trottleBanksFromJSON(json)
                completionHandler(banks, nil)
                
            case .Failure:
                let json = JSON(data: response.data!)
                
                let joiner = ", "
                var errors: [String] = []
                for result in json["errors"].arrayValue {
                    if let error = result["error"].string {
                        errors.append(error)
                    }
                }
                
                let message = errors.joinWithSeparator(joiner)
                let error = NSError(domain: "Throttle.Comms", code: response.result.error!.code, message: message)
                // Handles network timeouts, no connectivity, errors, and all fail cases.
                completionHandler(nil, error)
            }
        }
    }
    
	func downloadImage(url: NSURL, completionHandler: (String?, NSError?) -> Void)
    {
        let urlRequest = NSURLRequest(URL: url)
        
        var finalPath: NSURL? = nil
        
        afManager.download(urlRequest, destination: { (temporaryURL, response) in
            
            if let directoryURL: NSURL? = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] {
                
                let fileName = response.suggestedFilename!
                finalPath = directoryURL!.URLByAppendingPathComponent(fileName)
                return finalPath!
            }
            
            return temporaryURL
        })
            .response { (request, response, data, error) in
                
                if error != nil {
                    print(error)
                }
                
                completionHandler(finalPath?.path, error)
        }
    }
}
