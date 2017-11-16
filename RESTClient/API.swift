//
//  API.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

// This is "collection" of methods for REST requests to our server.
enum API {
    case login(email: String, password: String)
    case register(email: String, password: String, username: String)
    case logout(accessToken: String)
    case getUserAvatar(objectId: String, accessToken: String)
    case setUserAvatar(objectId: String, accessToken: String, url: String)
}

// A Requastable type is one that can generate a URLRequest object
// and it knows the type of the result that should be returned if
// the request is successful.
protocol Requestable {
    var urlRequest: URLRequest? { get }
}

// Our API conforms to the requestable protocol, we currently map
// each operation type to a Model object type. This extension is
// split into different methods for function paths, http payload,
// etc.
extension API : Requestable {
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
    
    // This is the function path after the base url
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
    
    // The http payload (e.g. for POST requests)
    fileprivate var httpBody: [String: String]? {
        var result: [String: String] = [:]
        
        switch self {
        case let .login(email, password):
            result[Constants.loginKey] = email
            result[Constants.passwordKey] = password
            
        case let .register(email, password, username):
            result[Constants.emailKey] = email
            result[Constants.passwordKey] = password
            result[Constants.usernameKey] = username
            
        case let .setUserAvatar(_, _, avatarUrl):
            result[Constants.avatarURLKey] = avatarUrl
            
        default:
            return nil
        }
        
        return result
    }
    
    fileprivate var httpHeaders: [String: String]? {
        var headers: [String: String] = [Constants.contentType: Constants.contentTypeJSON]
        
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
    
    // HTTP verb for each type of request
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

