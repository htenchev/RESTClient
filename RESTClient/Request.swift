//
//  Request.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

enum OperationResult {
    case register(RegistrationResult)
    case login(LoginResult)
    case logout(LogoutResult)
    case setAvatar(SetAvatarResult)
    case getAvatar(GetAvatarResult)
    
    func registrationResult() -> RegistrationResult? {
        if case .register(let result) = self {
            return result
        } else {
            return nil
        }
    }
    
    func loginResult() -> LoginResult? {
        if case .login(let result) = self {
            return result
        } else {
            return nil
        }
    }

    func logoutResult() -> LogoutResult? {
        if case .logout(let result) = self {
            return result
        } else {
            return nil
        }
    }

    func setAvatarResult() -> SetAvatarResult? {
        if case .setAvatar(let result) = self {
            return result
        } else {
            return nil
        }
    }

    func getAvatarResult() -> GetAvatarResult? {
        if case .getAvatar(let result) = self {
            return result
        } else {
            return nil
        }
    }
}

struct RequestError {
    let description: String
}
