//
//  IntegrationTests.swift
//  RESTClientTests
//
//  Created by Hristo Tentchev on 10/9/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import XCTest

class IntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin(exp: XCTestExpectation, requestable: Requestable) {
        
    }

    func testChain() {
        let exp = expectation(description: "LoginExpectation")
        
        RESTRequest().execute(requestable: API.register(email: "bilebile@abv.bg", password: "sdfsdsfs", username: "userneim")) { (op) in
            print("Result:\(op)")
            
            switch op {
            case .error(let errString):
                XCTAssert(false)
            }
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
