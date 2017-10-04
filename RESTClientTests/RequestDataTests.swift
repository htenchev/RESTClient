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
    
    func testInputOutputConsistency() {
        let register = API.register(email: "sdfsdf@mail.bg", password: "sdfhusdfy98sdf", username: "Ivan")
        let login = API.login(email: "sdfsdf@mail.bg", password: "sdfhusdfy98sdf")
        let logout = API.logout(accessToken: "sfsfd")
        let setAvatar = API.setUserAvatar(objectId: "345235-f34fwef", accessToken: "34fsdg", url: "brokenURL")
        let getAvatar = API.getUserAvatar(objectId: "sdfsdgfsg", accessToken: "e5tdfgsdfg")
        
        XCTAssert(CoolRequest<RegistrationResult>(requestable: register).isInputConsistentWithOutput())
        XCTAssert(CoolRequest<LoginResult>(requestable: login).isInputConsistentWithOutput())
        XCTAssert(CoolRequest<LogoutResult>(requestable: logout).isInputConsistentWithOutput())
        XCTAssert(CoolRequest<SetAvatarResult>(requestable: setAvatar).isInputConsistentWithOutput())
        XCTAssert(CoolRequest<GetAvatarResult>(requestable: getAvatar).isInputConsistentWithOutput())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
