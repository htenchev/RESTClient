//
//  API.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

enum API {
    case login(email: String, password: String)
    case register(email: String, password: String, username: String)
    case logout(accessToken: String)
    case getUserAvatar(objectId: String, accessToken: String)
    case setUserAvatar(objectId: String, accessToken: String, url: String)
}

protocol Requestable {
    var urlRequest: URLRequest? { get }
    var resultType: String { get }
}

extension API : Requestable {
    var resultType: String {
        var result = ""
        
        switch self {
        case .login: result = NSStringFromClass(LoginResult.self)
        case .register: result = NSStringFromClass(RegistrationResult.self)
        case .logout: result = NSStringFromClass(LogoutResult.self)
        case .setUserAvatar: result = NSStringFromClass(SetAvatarResult.self)
        case .getUserAvatar: result = NSStringFromClass(GetAvatarResult.self)
        }
        
        return result
    }
    
    var urlRequest: URLRequest? {
        let urlString = Constants.baseUrl + path;
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        if let body = httpBody {
            guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
                return nil
            }
            
            request.httpBody = bodyData
        }
        
        if let headers = httpHeaders {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        
        return request
     }
    
    fileprivate var path: String {
        switch self {
        case .login:
            return Constants.loginPath
        case .register:
            return Constants.registerPath
        case .logout:
            return Constants.logoutPath
        case .setUserAvatar(let objectId, _, _):
            return String(format: Constants.setUserInfoPath, objectId)
        case .getUserAvatar(let objectId, _):
            let info = [Constants.avatarURLKey, Constants.avatarRotationKey]
            let paramsString: String = "?props=" + info.joined(separator: ",")
            
            return String(format: Constants.getUserInfoPath + paramsString, objectId)
        }
    }
    
    fileprivate var httpBody: [String: String]? {
        var result: [String: String]? = [:]
        
        switch self {
        case let .login(email, password):
            result![Constants.loginKey] = email
            result![Constants.passwordKey] = password
            
        case let .register(email, password, username):
            result![Constants.emailKey] = email
            result![Constants.passwordKey] = password
            result![Constants.usernameKey] = username
            
        case let .setUserAvatar(_, _, avatarUrl):
            result![Constants.avatarURLKey] = avatarUrl
            
        default:
            result = nil
        }
        
        return result
    }
    
    fileprivate var httpHeaders: [String: String]? {
        var headers = [Constants.contentType: Constants.contentTypeJSON]
        
        switch self {
        case .logout(let accessToken),
             .setUserAvatar(_, let accessToken, _):
            headers[Constants.accessTokenKey] = accessToken
        case .getUserAvatar(_, _):
            return nil
            
        default:
            return headers
        }
        
        return headers
    }
    
    fileprivate var httpMethod: String {
        switch self {
        case .login, .register:
            return "POST"
        case .setUserAvatar:
            return "PUT"
            
        default:
            return "GET"
        }
    }
}

