//
//  IntegrationTests.swift
//  RESTClientTests
//
//  Created by Hristo Tentchev on 10/9/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import XCTest

class IntegrationTests: XCTestCase {
    var loggedInUserId: String = ""
    var accessToken: String = ""
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogout(expectation: XCTestExpectation) {
        let request = RESTRequest(API.logout(accessToken: accessToken))
        
        request.execute() { (result, err)  in
            XCTAssertNil(err, err!.description)
            expectation.fulfill()
        }
    }
    
    func testGetAvatar(expectation: XCTestExpectation) {
        let request = RESTRequest(API.setUserAvatar(objectId: loggedInUserId, accessToken: accessToken, url: "https://sitez.bg/cool1.jpg"))

        request.execute() { result, err in
            XCTAssertNotNil(result)
            XCTAssertNil(err, err!.description)
            XCTAssert(result!.setAvatarResult()!.isValid)
        }
    }

    func testSetAvatar(expectation: XCTestExpectation) {
        let request = RESTRequest(API.setUserAvatar(objectId: loggedInUserId, accessToken: accessToken, url: "https://sitez.bg/cool1.jpg"))

        request.execute() { [weak self] (result, err) in
            XCTAssertNil(err, err!.description)
            
            self?.testGetAvatar(expectation: expectation)
        }
    }
    
    func testChain() {
        let loginExpectation = expectation(description: "LoginExpectation")
        let request = RESTRequest(API.login(email: "bilebile@abv.bg", password: "sdfsdsfs"))
        
        request.execute() { [weak self] (result, err) in
            XCTAssertNil(err, err!.description)
            self?.testSetAvatar(expectation: loginExpectation)
        }
        
        wait(for: [loginExpectation], timeout: 30.0)
    }

    func testRegistration() {
        let exp = expectation(description: "RegExpectation")
        
        RESTRequest(API.register(email: "bilebile@abv.bg", password: "sdfsdsfs", username: "userneim")).execute() { result, err in
            XCTAssertNil(err)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
}
