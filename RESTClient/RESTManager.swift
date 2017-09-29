//
//  RESTManager.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/26/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

class RESTManager {
    static let sharedInstance = RESTManager()
    
    typealias AvatarCompletion = (UserAvatar?) -> Void
    
    func getLoggedUserAvatar(completion: @escaping AvatarCompletion) {
        let getAvatar = API.getUserInfo(objectId: loggedInObjectId, accessToken: accessToken, params: [Constants.avatarURLKey])
        
        execute(requestable: getAvatar) { (error: String, jsonDict: JSONDictionary?) in
            if (!error.isEmpty) {
                completion(nil)
                return
            }
            
            guard let dict = jsonDict else {
                completion(nil)
                return
            }
            
            let avatar = UserAvatar(with: dict)
            completion(avatar)
        }
    }
    
    func execute(requestable: API, completionHandler: @escaping CompletionHandler) {
        let req = RESTRequest()
        
        req.load(requestable: requestable, completion: {
            [weak self] (error: String, jsonDictionary: JSONDictionary?) in
            
            guard let dict = jsonDictionary else {
                self?.accessToken = ""
                completionHandler("Bad data", nil)
                return
            }
            
            if case .login = requestable {
                guard let tokenString = dict[Constants.accessTokenKey] as? String,
                    let objectId = dict[Constants.objectId] as? String else {
                        completionHandler("Bad token data in json", nil)
                        return
                }
                
                self?.accessToken = tokenString
                self?.loggedInObjectId = objectId
            }
            
            completionHandler("", dict)
        })
    }
    
    var accessToken: String = ""
    var loggedInObjectId: String = ""
}
