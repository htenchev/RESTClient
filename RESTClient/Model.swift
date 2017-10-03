//
//  Model.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/26/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation
import UIKit

struct UserAvatar {
    var url: String = ""
    
    init(with json: JSONDictionary) {
        if let urlString: String = json.value(forKey: Constants.avatarURLKey) {
            url = urlString
        }
    }
    
    var isValid: Bool {
        return !url.isEmpty && url.contains(Constants.validImageDomain) && url.contains(Constants.validImageFormat)
    }
}

protocol ModelType {
    associatedtype ConvertedType
    
    static func create(jsonDict: JSONDictionary) -> ConvertedType;
}

struct LoginResult : ModelType {
    var userToken: String = ""
    
    init(jsonDict: JSONDictionary) {
        
    }
    
    static func create(jsonDict: JSONDictionary) -> LoginResult {
        return LoginResult(jsonDict: jsonDict)
    }
}

struct RegistrationResult : ModelType {
    init(jsonDict: JSONDictionary) {
        
    }
    
    static func create(jsonDict: JSONDictionary) -> RegistrationResult {
        return RegistrationResult(jsonDict: jsonDict)
    }
}

struct LogoutResult : ModelType {
    init(jsonDict: JSONDictionary) {
        
    }
    
    static func create(jsonDict: JSONDictionary) -> LogoutResult {
        return LogoutResult(jsonDict: jsonDict)
    }
}

struct SetAvatarResult : ModelType {
    init(jsonDict: JSONDictionary) {
        
    }
    
    static func create(jsonDict: JSONDictionary) -> SetAvatarResult {
        return SetAvatarResult(jsonDict: jsonDict)
    }
}

struct GetAvatarResult : ModelType {
    init(jsonDict: JSONDictionary) {
        
    }
    
    static func create(jsonDict: JSONDictionary) -> GetAvatarResult {
        return GetAvatarResult(jsonDict: jsonDict)
    }
}

struct CoolRequest<ResourceType: ModelType> : APIRequest {
    func modelFromData(data: Data) -> ResourceType? {
        return ResourceType.create(jsonDict: JSONDictionary()) as? ResourceType
    }
}

