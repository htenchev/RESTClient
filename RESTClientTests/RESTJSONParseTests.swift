//
//  RequestDataTests.swift
//  RESTClientTests
//
//  Created by Hristo Tentchev on 10/4/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import XCTest
@testable import RESTClient

protocol ValidJSONGenerator {
    static func validJSON() -> JSONValue
}

extension RegistrationResult : ValidJSONGenerator {
    static func validJSON() -> JSONValue {
        return [
            Constants.emailKey: "todor@abv.bg",
            Constants.objectIdKey: "JKHASD-DS-sSDsdf-8sduf",
            Constants.usernameKey: "Todor Ludiqt"
        ]
    }
}

extension LoginResult : ValidJSONGenerator {
    static func validJSON() -> JSONValue {
        return [
            Constants.accessTokenKey : "slskdf-34-wf3-4f-f-sf",
            Constants.objectIdKey: "JJKASDD-DSF-SF-SDDF821"
        ]
    }
}

extension LogoutResult : ValidJSONGenerator {
    static func validJSON() -> JSONValue {
        return []
    }
}

extension SetAvatarResult : ValidJSONGenerator {
    static func validJSON() -> JSONValue {
        return [
            Constants.avatarURLKey : "http://sitez.bg/cool.jpg",
            Constants.avatarRotationKey : 10
        ]
    }
}

extension GetAvatarResult : ValidJSONGenerator {
    static func validJSON() -> JSONValue {
        return [
            Constants.avatarURLKey : "http://sitez.bg/cool.jpg",
            Constants.avatarRotationKey : 10
        ]
    }
}


class RequestDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPIOperationData(_ operation: API, _ desiredFailures: [RequestElement]) {
        for (requestElement, success) in operation.validate() {
            var shouldSucceed = true
            if (desiredFailures.contains(requestElement)) {
                shouldSucceed = false
            }
            
            XCTAssert(success == shouldSucceed, "\(requestElement) is bad.")
        }
    }
    
    func testLoginData() {
        testAPIOperationData(API.login(email: "", password: "sdfsdf23r23r"), [RequestElement.email])
        testAPIOperationData(API.login(email: "sdfsdf", password: ""), [RequestElement.password, RequestElement.email])
        testAPIOperationData(API.login(email: "sdfsdf@mail.bg", password: ""), [RequestElement.password])
        testAPIOperationData(API.login(email: "sdfsdf@mail.bg", password: "sdfhusdfy98sdf"), [])
    }
    
    func testRegistrationData() {
        testAPIOperationData(API.register(email: "", password: "sdfsdf23r23r", username: "Ivan"), [RequestElement.email])
        testAPIOperationData(API.register(email: "sdfsdf", password: "", username: "Ivan"), [RequestElement.password, RequestElement.email])
        testAPIOperationData(API.register(email: "sdfsdf@mail.bg", password: "", username: "Ivan"), [RequestElement.password])
        testAPIOperationData(API.register(email: "sdfsdf@mail.bg", password: "sdfhusdfy98sdf", username: "Ivan"), [])
        testAPIOperationData(API.register(email: "sdfsdf@mail.bg", password: "sdfhusdfy98sdf", username: ""), [])
    }
    
    func testLogoutData() {
        testAPIOperationData(API.logout(accessToken: ""), [RequestElement.accessToken])
        testAPIOperationData(API.logout(accessToken: "sdfsdjfkhsdfsiyudfysdjkhf-8sf76s87df-egfe-sdfe4f"), [RequestElement.accessToken])
    }
    
    func testGetAvatarData() {
        let goodToken = "sdfsdjfkhsdfsiyudfysdjkhf-8sf76s87df-egfe-sdfe4f"
        let badToken = ""
        
        testAPIOperationData(API.getUserAvatar(objectId: "", accessToken: badToken), [RequestElement.objectId, RequestElement.accessToken])
        testAPIOperationData(API.getUserAvatar(objectId: "fsdf98s0d9f8sdf", accessToken: goodToken), [])
    }
    
    func testSetAvatarData() {
        let goodToken = "sdfsdjfkhsdfsiyudfysdjkhf-8sf76s87df-egfe-sdfe4f"
        let badToken = ""
        let badUrl = "sjdfksjdkf"
        let goodUrl = "https://mydomain.bg/28934.jpg"
        let goodObjectId = "290348fijsfsdf90sdf"

        testAPIOperationData(API.setUserAvatar(objectId: "", accessToken: badToken, url: badUrl), [.objectId, .accessToken, .avatarURL])
        testAPIOperationData(API.setUserAvatar(objectId: "", accessToken: goodToken, url: goodUrl), [.objectId])
        testAPIOperationData(API.setUserAvatar(objectId: goodObjectId, accessToken: goodToken, url: goodUrl), [])
    }
        
    func testRegistrationResultParsing() {
        let json = RegistrationResult.validJSON()
        let regResult = RegistrationResult(data: json)
        
        // Test with correct data
        XCTAssert(regResult.email == "todor@abv.bg")
        XCTAssert(regResult.objectId == "JKHASD-DS-sSDsdf-8sduf")
        XCTAssert(regResult.username == "Todor Ludiqt")

        // Tests with missing fields
        guard var jsonDict = json as? JSONDictionary else {
            XCTAssert(false, "json data is not a dict")
            return
        }
        
        // Test missing mail
        jsonDict.removeValue(forKey: Constants.emailKey)
        var reg = RegistrationResult(data: jsonDict)
        XCTAssert(reg.email == "")
        
        // Test missing user id
        jsonDict.removeValue(forKey: Constants.objectIdKey)
        reg = RegistrationResult(data: jsonDict)
        XCTAssert(reg.objectId == "")
        
        // Test missing username
        jsonDict.removeValue(forKey: Constants.usernameKey)
        reg = RegistrationResult(data: jsonDict)
        XCTAssert(reg.username == "")
    }
    
    func testLoginResultParsing() {
        let json = LoginResult.validJSON()
        let loginResult = LoginResult(data: json)
        
        // Test with correct data
        XCTAssert(loginResult.userToken == "slskdf-34-wf3-4f-f-sf")
        XCTAssert(loginResult.objectId == "JJKASDD-DSF-SF-SDDF821")
        
        // Tests with missing fields
        guard var jsonDict = json as? JSONDictionary else {
            XCTAssert(false, "json data is not a dict")
            return
        }
        
        // Test missing aceessToken
        jsonDict.removeValue(forKey: Constants.accessTokenKey)
        var login = LoginResult(data: jsonDict)
        XCTAssert(login.userToken == "")
        
        // Test missing user id
        jsonDict.removeValue(forKey: Constants.objectIdKey)
        login = LoginResult(data: jsonDict)
        XCTAssert(login.objectId == "")
    }
    
    func testLogutResultParsing() {
        let json = LogoutResult.validJSON()
        //let logoutResult = LogoutResult(data: json)
        
        guard var _ = json as? JSONDictionary else {
            XCTAssert(false, "json data is not a dict")
            return
        }
    }
    
    func testSetAvatarResultParsing() {
        let json = SetAvatarResult.validJSON()
        let setAvatarRes = SetAvatarResult(data: json)
        
        guard var jsonDict = json as? JSONDictionary else {
            XCTAssert(false, "json data is not a dict")
            return
        }
        
        // Test with correct data
        XCTAssertEqual(setAvatarRes.avatarURL, "http://sitez.bg/cool.jpg")
        
        // Test with a missing avatar field
        jsonDict.removeValue(forKey: Constants.avatarURLKey)
        let avatarRes = SetAvatarResult(data: jsonDict)
        XCTAssertEqual(avatarRes.avatarURL, "")
    }
    
    func testGetAvatarRеsultParsing() {
        let json = GetAvatarResult.validJSON()
        let getAvatarRes = GetAvatarResult(data: json)
        
        guard var jsonDict = json as? JSONDictionary else {
            XCTAssert(false, "json data is not a dict")
            return
        }
        
        // Test with correct data
        XCTAssertEqual(getAvatarRes.avatarURL, "http://sitez.bg/cool.jpg")
        
        // Test with a missing avatar field
        jsonDict.removeValue(forKey: Constants.avatarURLKey)
        let avatarRes = GetAvatarResult(data: jsonDict)
        XCTAssertEqual(avatarRes.avatarURL, "")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
