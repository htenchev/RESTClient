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
            let correctHeaders = headers {
            XCTAssertEqual(requestHeaders, correctHeaders)
        }
        
        if let method = request.httpMethod {
            XCTAssertEqual(method, httpMethod)
        }
        
        if let payload = request.httpBody, let correctPayloadJSON = body {
            guard let myPayloadData = try? JSONSerialization.data(withJSONObject: payload, options: []),
            let correctPayloadData = try? JSONSerialization.data(withJSONObject: correctPayloadJSON, options: []) else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(myPayloadData, correctPayloadData)
            
            if let token = correctPayloadJSON[Constants.accessTokenKey] {
                XCTAssertFalse(token.isEmpty)
            }
        }
    }
    
    func testRegistrationRequestData() {
        let mail = "userttt@mailll.bg"
        let password = "sdfsdf"
        let username = "User Name"
        let registration = API.register(email: mail, password: password, username: username)
        let regHeaders = [Constants.contentType : Constants.contentTypeJSON]
        let regBody = [Constants.emailKey : mail, Constants.passwordKey : password, Constants.usernameKey : username]
        
        guard let url = registration.urlRequest?.url else {
            return
        }
        
        testURL(url, Constants.registerPath)
        testAPIRequestTransform(myRequest: registration, httpMethod: "POST", headers: regHeaders, body: regBody)
    }
    
    func testLoginRequestData() {
        let mail = "userttt@mailll.bg"
        let password = "sdfsdf"
        let login = API.login(email: mail, password: password)
        let regHeaders = [Constants.contentType : Constants.contentTypeJSON]
        let regBody = [Constants.loginKey : mail, Constants.passwordKey : password]
        
        guard let url = login.urlRequest?.url else {
            return
        }
        
        testURL(url, Constants.loginPath)
        testAPIRequestTransform(myRequest: login, httpMethod: "POST", headers: regHeaders, body: regBody)
    }
    
    func testSetUserInfoRequestData() {
        let objectId = "SJHFGS879-SDMFSDF6-FVSDJF68SD7F-SJKGHFJGSDF"
        let accessToken = "sjkdfhskdf-3f-s-f-adjhbajskdhagsjd"
        let url = "http://mydomain.bg/mypic.jpg"
        let setUserInfo = API.setUserAvatar(objectId: objectId, accessToken: accessToken, url: url)
        let userInfoToSet = [Constants.avatarURLKey: url]
        let headers = [Constants.contentType : Constants.contentTypeJSON,
                      Constants.accessTokenKey : accessToken]
        
        guard let myUrl = setUserInfo.urlRequest?.url else {
            return
        }
        
        testURL(myUrl, "/users/")
        testAPIRequestTransform(myRequest: setUserInfo, httpMethod: "PUT", headers: headers, body: userInfoToSet)
    }
    
    func testGetUserInfoRequestData() {
        let objectId = "SJHFGS879-SDMFSDF6-FVSDJF68SD7F-SJKGHFJGSDF"
        let accessToken = "sjkdfhskdf-3f-s-f-adjhbajskdhagsjd"
        let getUserInfo = API.getUserAvatar(objectId: objectId, accessToken: accessToken)
        
        let headers = [Constants.contentType : Constants.contentTypeJSON,
                       Constants.accessTokenKey : accessToken]
        
        guard let url = getUserInfo.urlRequest?.url else {
            return
        }
        
        testURL(url, "/users/")
        testAPIRequestTransform(myRequest: getUserInfo, httpMethod: "GET", headers: headers, body: nil)
    }
    
    func testLogoutRequestData() {
        let token = "SKJHDFSDF23-F2-3D-23D23D2FSG"
        let logout = API.logout(accessToken: token)
        
        let headers = [Constants.contentType : Constants.contentTypeJSON, Constants.accessTokenKey : token]
        
        guard let url = logout.urlRequest?.url else {
            return
        }
        
        testURL(url, Constants.logoutPath)
        testAPIRequestTransform(myRequest: logout, httpMethod: "GET", headers: headers, body: nil)
    }
    
    func testURL(_ url: URL, _ expectedFunctionPath: String) {
        let urlString = url.absoluteString
        
        // Check baseurl
        XCTAssert(urlString.contains(Constants.baseUrl))
        
        // Check https
        XCTAssert(urlString.contains("https://"))
        
        // Check function path
        XCTAssert(urlString.contains(expectedFunctionPath))
    }
    
        
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
