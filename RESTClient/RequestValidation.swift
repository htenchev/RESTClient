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

// We check if our input is valid and return details about it:
// The result tells which elements passed validation, and which
// did not by using the InputValidationResult type.
protocol RequestInputValidation {
    typealias InputValidationResult = [RequestElement: Bool]
    func validate() -> InputValidationResult
}

extension API : RequestInputValidation {
    typealias ElementValidator = (String) -> Bool
    
    // We perform validation by different functors for the different fields.
    func validate() -> InputValidationResult {
        var result: InputValidationResult = [:];
        var args: [String] = []
        var types: [RequestElement] = []
        
        switch self {
        case let .register(email, password, username):
            args = [email, password, username]
            types = [.email, .password, .username]
            
        case let .login(email, password):
            args = [email, password]
            types = [.email, .password]

        case let .setUserAvatar(objectId, token, _):
            args = [objectId, token]
            types = [.objectId, .accessToken]
            
        case let .getUserAvatar(objectId, token):
            args = [objectId, token]
            types = [.objectId, .accessToken]

        case let .logout(token):
            args = [token]
            types = [.accessToken]
        }
        
        for (elemType, arg) in zip(types, args) {
            result[elemType] = validatorFor(element: elemType)(arg)
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
