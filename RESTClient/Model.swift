//
//  Model.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/26/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation
import UIKit

protocol ModelType {
    associatedtype ConvertedType
    static func create(data: JSONValue) -> ConvertedType;
}

struct LoginResult : ModelType {
    let userToken: String
    let objectId: String
    
    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
        let tokenValue = dict[Constants.accessTokenKey] as? String,
        let objectIdValue = dict[Constants.objectIdKey] as? String else {
            userToken = ""
            objectId = ""
                
            return
        }
        
        userToken = tokenValue
        objectId = objectIdValue
    }
    
    static func create(data: JSONValue) -> LoginResult {
        return LoginResult(data: data)
    }
}

struct RegistrationResult : ModelType {
    let email: String
    let objectId: String
    let username: String
    
    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
        let usernameValue = dict[Constants.usernameKey] as? String,
        let objectIdValue = dict[Constants.objectIdKey] as? String,
        let emailValue = dict[Constants.emailKey] as? String else {
                email = ""
                objectId = ""
                username = ""
                
                return
        }
        
        email = emailValue
        objectId = objectIdValue
        username = usernameValue
    }
    
    static func create(data: JSONValue) -> RegistrationResult {
        return RegistrationResult(data: data)
    }
}

struct LogoutResult : ModelType {
    init(data: JSONValue) {
        
    }
    
    static func create(data: JSONValue) -> LogoutResult {
        return LogoutResult(data: data)
    }
}

struct SetAvatarResult : ModelType {
    let avatarURL: String

    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
        let avatarURLValue = dict[Constants.avatarURLKey] as? String else {
            avatarURL = ""
            return
        }
        
        avatarURL = avatarURLValue
    }
    
    var isValid: Bool {
        return avatarURL.contains(".bg") && avatarURL.contains(".jpg")
    }
    
    static func create(data: JSONValue) -> SetAvatarResult {
        return SetAvatarResult(data: data)
    }
}

struct GetAvatarResult : ModelType {
    let avatarURL: String
    
    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
        let avatarURLValue = dict[Constants.usernameKey] as? String else {
            avatarURL = ""
            return
        }
        
        avatarURL = avatarURLValue
    }
    
    var isValid: Bool {
        return avatarURL.contains(".bg") && avatarURL.contains(".jpg")
    }
    
    static func create(data: JSONValue) -> GetAvatarResult {
        return GetAvatarResult(data: data)
    }
}

