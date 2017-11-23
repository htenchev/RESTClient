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
    
    
    func testRequestChain() {
        let loginExpectation = expectation(description: "LoginExpectation")
        var token = ""
        var userId = ""
        let chain = RequestChain()
        
        chain.add(.login(email: "bilebile@abv.bg", password: "sdfsdsfs")) { (res, err) in
            if let result = res,
                let loginRes = result.loginResult() {
                token = loginRes.userToken
                userId = loginRes.objectId
            } else {
                return false
            }
            
            return true
        }.add(.setUserAvatar(objectId: userId, accessToken: token, url: "https://sitez.bg/cool1.jpg")) { res, err in
            print("Set user avatar")
            return true;
        }.add(.getUserAvatar(objectId: userId, accessToken: token)) { (res, err) in
            print("Got user avatar")
            return true
        }.add(.logout(accessToken: token)) { (res, err) in
            print("Logout")
            loginExpectation.fulfill()
            return true
        }.execute()
        
        wait(for: [loginExpectation], timeout: 60.0)
    }

    func testRegistration() {
        let exp = expectation(description: "RegExpectation")
        
        API.register(email: "bilebile@abv.bg", password: "sdfsdsfs", username: "userneim").execute() { result, err in
            XCTAssertNil(err)
            exp.fulfill()
            return true
        }
        
        wait(for: [exp], timeout: 5.0)
    }
}
