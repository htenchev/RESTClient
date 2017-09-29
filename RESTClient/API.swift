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

extension API : RequestInputValidation {
    typealias ElementValidator = (String) -> Bool
    
    func isValid() -> InputValidationResult {
        var result: InputValidationResult = [:];
        
        switch self {
        case let .login(email, password):
            result[.email] = validatorFor(element: .email)(email)
            result[.password] = validatorFor(element: .password)(password)
            
        case let .register(email, password, username):
            result[.email] = validatorFor(element: .email)(email)
            result[.password] = validatorFor(element: .password)(password)
            result[.username] = validatorFor(element: .username)(username)
            
        case let .setUserInfo(objectId, token, _): // TODO: params validation
            result[RequestElement.accessToken] = validatorFor(element: .accessToken)(token)
            result[.objectId] = validatorFor(element: .objectId)(objectId)
            
        case let .getUserInfo(objectId, token, _): // TODO params validation
            result[RequestElement.accessToken] = validatorFor(element: .accessToken)(token)
            result[.objectId] = validatorFor(element: .objectId)(objectId)
            
        case let .logout(token):
            result[RequestElement.accessToken] = validatorFor(element: .accessToken)(token)
        }
        
        return result
    }
    
    private func validatorFor(element: RequestElement) -> ElementValidator {
        switch element {
        case .email:
            return validateEmail
        case .password:
            return validatePassword
        case .username:
            return validateUsername
        case .accessToken, .objectId:
            return validateAny
        case .setUserInfoParams, .getUserInfoParams:
            return validateUserInfoParam
        }
    }
    
    private func validateEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "%@", emailRegex).evaluate(with: email)
    }
    
    private func validatePassword(password: String) -> Bool {
        return !password.isEmpty && password.characters.count >= 8
    }
    
    private func validateUsername(username: String) -> Bool {
        return !username.isEmpty
    }
    
    private func validateAny(item: String) -> Bool {
        return !item.isEmpty;
    }
    
    private func validateUserInfoParam(item: String) -> Bool {
        return validateAny(item: item)
    }
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
