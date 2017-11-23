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
        let chain = RequestChain()
        var token = ""
        var objectId = ""
        
        chain.firstly { chainer in
            chainer.add(.login(email: "bilebile@abv.bg", password: "sdfsdsfs"))
        }.then { (res, err, chainer) in
            guard let loginRes = res?.loginResult() else {
                return false
            }
            
            token = loginRes.userToken
            objectId = loginRes.objectId
            chainer.add(.setUserAvatar(objectId: objectId, accessToken: token, url: "https://sitez.bg/cool1.jpg"))
            
            return true
        }.then { (err, res, chainer) in
            chainer.add(.logout(accessToken: token))
            return true
        }.then { (err, res, chainer) in
            loginExpectation.fulfill()
            return true
        }.execute()
        
//        chain.add(.login(email: "bilebile@abv.bg", password: "sdfsdsfs")) { (res, err) in
//            if let result = res,
//                let loginRes = result.loginResult() {
//                token = loginRes.userToken
//                userId = loginRes.objectId
//            } else {
//                return false
//            }
//
//            return true
//        }.add(.setUserAvatar(objectId: userId, accessToken: token, url: "https://sitez.bg/cool1.jpg")) { res, err in
//            print("Set user avatar")
//            return true;
//        }.add(.getUserAvatar(objectId: userId, accessToken: token)) { (res, err) in
//            print("Got user avatar")
//            return true
//        }.add(.logout(accessToken: token)) { (res, err) in
//            print("Logout")
//            loginExpectation.fulfill()
//            return true
//        }.execute()
        
        wait(for: [loginExpectation], timeout: 260.0)
    }

    func testRegistration() {
        let exp = expectation(description: "RegExpectation")
        
        // Already registered
        API.register(email: "bilebile@abv.bg", password: "sdfsdsfs", username: "userneim").execute() { result, err in
            XCTAssertNotNil(err)
            exp.fulfill()
            return true
        }
        
        wait(for: [exp], timeout: 5.0)
    }
}
