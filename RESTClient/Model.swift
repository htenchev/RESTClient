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
    var userToken: String = ""
    var objectId: String = ""
    
    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
            let tokenValue = dict[Constants.accessTokenKey] as? String,
            let objectIdValue = dict[Constants.objectId] as? String else {
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
    var email: String = ""
    var objectId: String = ""
    var username: String = ""
    
    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
        let usernameValue = dict[Constants.usernameKey] as? String,
        let objectIdValue = dict[Constants.objectId] as? String,
        let emailValue = dict[Constants.emailKey] as? String else {
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
    var avatarURL: String = ""

    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
            let avatarURLValue = dict[Constants.usernameKey] as? String else {
                return
        }

        avatarURL = avatarURLValue
    }
    
    static func create(data: JSONValue) -> SetAvatarResult {
        return SetAvatarResult(data: data)
    }
}

struct GetAvatarResult : ModelType {
    var avatarURL: String = ""
    
    init(data: JSONValue) {
        guard let dict = data as? JSONDictionary,
            let avatarURLValue = dict[Constants.usernameKey] as? String else {
                return
        }
        
        avatarURL = avatarURLValue
    }
    
    static func create(data: JSONValue) -> GetAvatarResult {
        return GetAvatarResult(data: data)
    }
}

