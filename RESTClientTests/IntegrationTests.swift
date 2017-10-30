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
        let request = RESTRequest()
        
        request.execute(requestable: API.logout(accessToken: accessToken)) { (op) in
            if case OperationResult.logout = op {
                expectation.fulfill()
            } else if case OperationResult.error(let errorMessage) = op {
                XCTAssert(false, errorMessage)
            } else {
                XCTAssert(false)
            }
        }
    }
    
    func testGetAvatar(expectation: XCTestExpectation) {
        let request = RESTRequest()
        
        request.execute(requestable: API.setUserAvatar(objectId: loggedInUserId, accessToken: accessToken, url: "https://sitez.bg/cool1.jpg")) { (op) in

            if case OperationResult.setAvatar(let avatarResult) = op {
                XCTAssert(avatarResult.isValid)
            } else if case OperationResult.error(let errorMessage) = op {
                XCTAssert(false, errorMessage)
            }
            else {
                XCTAssert(false)
            }
        }
    }
    
    func testSetAvatar(expectation: XCTestExpectation) {
        let request = RESTRequest()
        
        request.execute(requestable: API.setUserAvatar(objectId: loggedInUserId, accessToken: accessToken, url: "https://sitez.bg/cool1.jpg")) { [weak self] (op) in
            
            if case OperationResult.setAvatar(let avatarResult) = op {
                XCTAssert(avatarResult.isValid)
                self?.testGetAvatar(expectation: expectation)
            } else if case OperationResult.error(let errorMessage) = op {
                XCTAssert(false, errorMessage)
            }
            else {
                XCTAssert(false)
            }
        }
    }
    
    func testLogin() {
        let loginExpectation = expectation(description: "LoginExpectation")
        let request = RESTRequest()
        
        request.execute(requestable: API.login(email: "bilebile@abv.bg", password: "sdfsdsfs")) { [weak self] (op) in
            switch op {
            case .error(let errorMessage):
                XCTAssert(false)
                print("Error: \(errorMessage)")
            case .login(let loginResult):
                print(">>> Login: User-token [\(loginResult.userToken)]")
                
                self?.testSetAvatar(expectation: loginExpectation)
            default:
                print("")
                XCTAssert(false)
            }
        }
    }

    func testRegistration() {
        let exp = expectation(description: "RegExpectation")
        
        RESTRequest().execute(requestable: API.register(email: "bilebile@abv.bg", password: "sdfsdsfs", username: "userneim")) { (op) in
            print("Result:\(op)")
            
            switch op {
            case .error:
                XCTAssert(false)
            default:
                print("Non error")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func testChain() {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
