//
//  API.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

enum API {
    typealias GetUserInfoParams = [String]
    typealias SetUserInfoParams = [String: String]
    
    case login(email: String, password: String)
    case register(email: String, password: String, username: String)
    case logout(accessToken: String)
    case getUserInfo(objectId: String, accessToken: String, params: GetUserInfoParams)
    case setUserInfo(objectId: String, accessToken: String, info: SetUserInfoParams)
}

protocol Requestable {
    var urlRequest: URLRequest? { get }
}

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
    
    fileprivate var path: String {
        switch self {
        case .login:
            return Constants.loginPath
        case .register:
            return Constants.registerPath
        case .logout:
            return Constants.logoutPath
        case .setUserInfo(let objectId, _, _):
            return String(format: Constants.setUserInfoPath, objectId)
        case .getUserInfo(let objectId, _, let info):
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
            
        case let .setUserInfo(_, _, info):
            result = info
            
        default:
            result = nil
        }
        
        return result
    }
    
    fileprivate var httpHeaders: [String: String]? {
        var headers = [Constants.contentType: Constants.contentTypeJSON]
        
        switch self {
        case .logout(let accessToken),
             .setUserInfo(_, let accessToken, _):
            headers[Constants.accessTokenKey] = accessToken
        case .getUserInfo(_, _, _):
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
        case .setUserInfo:
            return "PUT"
            
        default:
            return "GET"
        }
    }
}

