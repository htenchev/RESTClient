//
//  RequestValidation.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 10/3/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

enum RequestElement : String {
    case username, password, email, accessToken, avatarURL, objectId
}

protocol RequestInputValidation {
    typealias InputValidationResult = [RequestElement: Bool]
    func validate() -> InputValidationResult
}

extension API : RequestInputValidation {
    typealias ElementValidator = (String) -> Bool
    
    func validate() -> InputValidationResult {
        var result: InputValidationResult = [:];
        
        switch self {
        case let .register(email, password, username):
            result[.email] = validatorFor(element: .email)(email)
            result[.password] = validatorFor(element: .password)(password)
            result[.username] = validatorFor(element: .username)(username)
            
        case let .login(email, password):
            result[.email] = validatorFor(element: .email)(email)
            result[.password] = validatorFor(element: .password)(password)
            
        case let .setUserAvatar(objectId, token, _): // TODO: params validation
            result[RequestElement.accessToken] = validatorFor(element: .accessToken)(token)
            result[.objectId] = validatorFor(element: .objectId)(objectId)
            
        case let .getUserAvatar(objectId, token): // TODO params validation
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
        case .avatarURL:
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
