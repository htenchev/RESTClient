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

        request.execute() { [weak self] result, err in
            XCTAssertNil(err, err!.description)
            
            guard let res = result, let avatarRes = res.getAvatarResult() else {
                XCTFail("nil result")
                return
            }
            
            XCTAssert(avatarRes.isValid)
            self?.testLogout(expectation: expectation)
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
            
            guard let r = result, let loginData = r.loginResult() else {
                XCTFail()
                return
            }
            
            self?.loggedInUserId = loginData.objectId
            self?.accessToken = loginData.userToken
            self?.testSetAvatar(expectation: loginExpectation)
        }
        
        wait(for: [loginExpectation], timeout: 60.0)
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
