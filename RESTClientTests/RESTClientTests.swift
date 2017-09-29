//
//  RESTClientTests.swift
//  RESTClientTests
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import XCTest
@testable import RESTClient

class RESTClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPIRequestTransform(myRequest: API, httpMethod: String, headers: [String: String]?, body: [String: String]?) {
        guard let request = myRequest.urlRequest else {
            XCTAssert(false)
            return
        }
        
        if let requestHeaders = request.allHTTPHeaderFields,
            let myHeaders = myRequest.httpHeaders,
            let correctHeaders = headers {
            XCTAssertEqual(requestHeaders, myHeaders)
            XCTAssertEqual(myHeaders, correctHeaders)
        }
        
        if let method = request.httpMethod {
            XCTAssertEqual(method, myRequest.httpMethod)
            XCTAssertEqual(method, httpMethod)
        }
        
        if let payload = request.httpBody, let myPayload = myRequest.httpBody, let correctPayloadJSON = body {
            guard let myPayloadData = try? JSONSerialization.data(withJSONObject: myPayload, options: []),
            let correctPayloadData = try? JSONSerialization.data(withJSONObject: correctPayloadJSON, options: []) else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(payload, myPayloadData)
            XCTAssertEqual(myPayloadData, correctPayloadData)
            
            if let token = correctPayloadJSON[Constants.accessTokenKey] {
                XCTAssertFalse(token.isEmpty)
            }
        }
    }
    
    func testRegData() {
        let mail = "userttt@mailll.bg"
        let password = "sdfsdf"
        let username = "User Name"
        let registration = API.register(email: mail, password: password, username: username)
        
        XCTAssert(registration.isValid)
    }
    
    func testRegistrationRequestData() {
        let mail = "userttt@mailll.bg"
        let password = "sdfsdf"
        let username = "User Name"
        let registration = API.register(email: mail, password: password, username: username)
        let regHeaders = [Constants.contentType : Constants.contentTypeJSON]
        let regBody = [Constants.emailKey : mail, Constants.passwordKey : password, Constants.usernameKey : username]
        
        testAPIRequestTransform(myRequest: registration, httpMethod: "POST", headers: regHeaders, body: regBody)
    }
    
    func testLoginRequestData() {
        let mail = "userttt@mailll.bg"
        let password = "sdfsdf"
        let registration = API.login(email: mail, password: password)
        
        let regHeaders = [Constants.contentType : Constants.contentTypeJSON]
        let regBody = [Constants.loginKey : mail, Constants.passwordKey : password]
        
        testAPIRequestTransform(myRequest: registration, httpMethod: "POST", headers: regHeaders, body: regBody)
    }
    
    func testSetUserInfoRequestData() {
        let objectId = "SJHFGS879-SDMFSDF6-FVSDJF68SD7F-SJKGHFJGSDF"
        let accessToken = "sjkdfhskdf-3f-s-f-adjhbajskdhagsjd"
        let userInfoToSet = [Constants.avatarURLKey : "http://mydomain.bg/mypic.jpg"]
        let setUserInfo = API.setUserInfo(objectId: objectId, accessToken: accessToken, info: userInfoToSet)
        
        let headers = [Constants.contentType : Constants.contentTypeJSON,
                      Constants.accessTokenKey : accessToken]
        
        testAPIRequestTransform(myRequest: setUserInfo, httpMethod: "PUT", headers: headers, body: userInfoToSet)
    }
    
    func testGetUserInfoRequestData() {
        let objectId = "SJHFGS879-SDMFSDF6-FVSDJF68SD7F-SJKGHFJGSDF"
        let accessToken = "sjkdfhskdf-3f-s-f-adjhbajskdhagsjd"
        let userInfoToGet = [Constants.avatarURLKey]
        let getUserInfo = API.getUserInfo(objectId: objectId, accessToken: accessToken, params: userInfoToGet)
        
        let headers = [Constants.contentType : Constants.contentTypeJSON,
                       Constants.accessTokenKey : accessToken]
        
        testAPIRequestTransform(myRequest: getUserInfo, httpMethod: "GET", headers: headers, body: nil)
    }
    
    func testLogoutRequestData() {
        let token = "SKJHDFSDF23-F2-3D-23D23D2FSG"
        let logout = API.logout(accessToken: token)
        
        let headers = [Constants.contentType : Constants.contentTypeJSON, Constants.accessTokenKey : token]
        
        testAPIRequestTransform(myRequest: logout, httpMethod: "GET", headers: headers, body: nil)
    }
    
    func testLogout(asyncExpectation: XCTestExpectation) {
        let rest = RESTManager.sharedInstance
        let logout = API.logout(accessToken: rest.accessToken)
        
        rest.execute(requestable: logout) { (error, data) in
            if (!error.isEmpty) {
                print("Error: \(error)")
                XCTAssert(false)
                asyncExpectation.fulfill()
                return
            }
            
            asyncExpectation.fulfill()
        }
    }
    
    func testGetAvatar(asyncExpectation: XCTestExpectation) {
        let rest = RESTManager.sharedInstance
        let fields = [Constants.avatarURLKey, Constants.avatarRotationKey]
        let getInfo = API.getUserInfo(objectId: rest.loggedInObjectId, accessToken: rest.accessToken, params: fields)
        
        rest.execute(requestable: getInfo) { [weak self] (error, data) in
            if (!error.isEmpty) {
                print("Error: \(error)")
                XCTAssert(false)
                asyncExpectation.fulfill()
                return
            }
            
            self?.testLogout(asyncExpectation: asyncExpectation)
        }
    }
    
    func testSetAvatar(asyncExpectation: XCTestExpectation) {
        let rest = RESTManager.sharedInstance
        let info = ["avatarURL": "https://wwww.namenamename.com/avatar213.jpg",
                    "avatarRotation": "90"]
        let setInfo = API.setUserInfo(objectId: rest.loggedInObjectId, accessToken: rest.accessToken, info: info)
        
        rest.execute(requestable: setInfo) { [weak self] (error, data) in
            if (!error.isEmpty) {
                print("Error: \(error)")
                XCTAssert(false)
                asyncExpectation.fulfill()
                return
            }
            
            self?.testGetAvatar(asyncExpectation: asyncExpectation)
        }
    }
    
    func testRequestChain() {
        let login = API.login(email: "sdjkf@adfsdf.dfg", password: "password23")
        let theExpectation = expectation(description: "lre")
        let rest = RESTManager.sharedInstance
        
        rest.execute(requestable: login) { [weak self] (error, data) in
            if (!error.isEmpty) {
                print("Error: \(error)")
                XCTAssert(false)
                theExpectation.fulfill()
                return
            }
            
            self?.testSetAvatar(asyncExpectation: theExpectation)
        }
        
        wait(for: [theExpectation], timeout: 200.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
