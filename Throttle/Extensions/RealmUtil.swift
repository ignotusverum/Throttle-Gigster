//
//  RealmExtension.swift
//  Throttle
//
//  Created by Marco Ledesma on 3/20/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift;
import Locksmith;

class RealmUtil {
	static var cachedDataKey: NSData?;
	
	static func getDatabaseKey() throws -> NSData? {
		if let databaseKey = cachedDataKey {
			return databaseKey;
		}
		
		var data = Locksmith.loadDataForUserAccount("RealmDatabase");
		var key = data?["key"] as? NSData;
		
		if (data == nil || key == nil) {
			print("Database key not found. Generating a new one");
			let mutableKey = NSMutableData(length: 64)!;
			SecRandomCopyBytes(kSecRandomDefault, mutableKey.length, UnsafeMutablePointer<UInt8>(mutableKey.mutableBytes));
			
			try Locksmith.saveData(["key": mutableKey], forUserAccount: "RealmDatabase");
			key = NSData(data: mutableKey)
			print("Database key generated");
		}
		
		RealmUtil.cachedDataKey = key;
		return key;
	}
}

extension Realm {
	static func getEncryptedInstance() throws -> Realm {
		let key = try RealmUtil.getDatabaseKey();
		var config = Realm.Configuration(encryptionKey: key);
		config.schemaVersion = 3;
		
		return try Realm(configuration: config);
	}
  
  func deleteAccount(account:UserAccountEntity) {
    do {
      let realm = try Realm.getEncryptedInstance();
      realm.beginWrite()
      realm.delete(account)
      
      try realm.commitWrite()
    } catch {
      print(error)
    }
  }
	
}
