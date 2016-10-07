//
//  SnowballAvalancheCalculationServiceTest.swift
//  Throttle
//
//  Created by Marco Ledesma on 4/25/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import XCTest
@testable import Throttle

class SnowballAvalancheCalculationServiceTest: XCTestCase {
	
    
    func testExample() {
		let snowballAvalanceService = SnowballAvalancheCalculationService(logDetails: true);
		let result = snowballAvalanceService.executeWithSnowballAlgorithm(false);
		
		XCTAssert(result.code == .Success);
		print("Ending Date: \(result.endingDate)");
    }
    
 
    
}
