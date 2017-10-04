//
//  RequestDataTests.swift
//  RESTClientTests
//
//  Created by Hristo Tentchev on 10/4/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import XCTest

class RequestDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLoginData() {
        let requestable = API.login(email: "", password: "sdfsdf")
        
        for (requestElement, success) in requestable.validate() {
            XCTAssert(success, "\(requestElement) is bad.")
        }
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
