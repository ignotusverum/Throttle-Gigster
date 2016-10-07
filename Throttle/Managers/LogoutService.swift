//
//  LogoutService.swift
//  Throttle
//
//  Created by Marco Ledesma on 2/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift;
import Crashlytics;

class LogoutService: BaseService {
	let deleteUrl = NSURL(string:"\(Config.getWebAPIURL())/users/sign_out")!;
	let auth : AuthProtocol;
	
	init(auth: AuthProtocol) {
		self.auth = auth;
	}
	
	func execute(completionHandler: (success: Bool) -> Void) {
		let mutableURLRequest = self.getMutableRequest(self.deleteUrl, apiMethod: .DELETE, token: auth.getAuthenticatedUser()!.token);
		self.afManager.request(mutableURLRequest).validate().responseJSON { response in
			do {
				let realm = try Realm.getEncryptedInstance();
				try realm.write {
					realm.deleteAll();
				}
				
				self.auth.removeAuthenticatedUserData();
				self.auth.setAuthenticatedUsingTouchID(false);
				NSUserDefaults.setTotalMonthlyMinimumPayment(0);
				NSUserDefaults.setCalculationAlgorithm(nil)
			}
			catch {
				CLSLogv("Realm Error: %@", getVaList(["\(error)"]));
				Crashlytics.sharedInstance().throwException();
			}
			
			
			
			switch response.result {
			case .Success:
				completionHandler(success: true);
				break;
			default:
				completionHandler(success: false);
				break;
			}
		};
	}
}
