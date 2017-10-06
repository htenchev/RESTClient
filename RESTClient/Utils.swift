//
//  Utils.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/28/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

struct Constants {
    static let baseUrl = "https://api.backendless.com/9BA1D5A0-43CF-E11A-FFFF-C935004D8E00/C2C14556-C521-00AC-FF38-34F9C1027000/"
    
    // Function paths
    static let registerPath = "users/register"
    static let loginPath = "users/login"
    static let logoutPath = "users/logout"
    static let setUserInfoPath = "users/%@" // user id
    static let getUserInfoPath = "users/%@" // user id
    
    // JSON keys
    static let usernameKey = "username"
    static let passwordKey = "password"
    static let loginKey = "login"
    static let emailKey = "email"
    static let accessTokenKey = "user-token"
    static let avatarURLKey = "avatarURL"
    static let avatarRotationKey = "avatarRotation"
    static let objectIdKey = "objectId"
    
    // Headers
    static let contentType = "Content-Type"
    static let contentTypeJSON = "application/json"
    
    // Misc
    static let validImageDomain = "mydomain.bg"
    static let validImageFormat = ".jpg"
}

func prettyPrintData(data: Data) {
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
        print("jsonObject(with::) failed")
        return
    }
    
    guard let prettyDataObj = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
        print("data(withJSONObject:: failed.")
        return
    }
    
    String(data: prettyDataObj, encoding: String.Encoding.utf8).map { print("Data:\($0)") }
}



