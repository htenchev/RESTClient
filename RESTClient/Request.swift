//
//  Request.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

struct Constants {
    static let baseUrl = "https://api.backendless.com/9BA1D5A0-43CF-E11A-FFFF-C935004D8E00/C2C14556-C521-00AC-FF38-34F9C1027000/"
    
    // Function paths
    static let registerPath = "users/register"
    static let loginPath = "users/login"
    static let logoutPath = "users/logout"
    static let setUserInfoPath = "users/%@" // user id
    static let getUserInfoPath = "users/%@" // user id
    
    // JSON keys
    static let usernameKey = "username"
    static let passwordKey = "password"
    static let loginKey = "login"
    static let emailKey = "email"
    static let accessTokenKey = "user-token"
    static let avatarURLKey = "avatarURL"
    static let avatarRotationKey = "avatarRotation"
    static let objectId = "objectId"
    
    // Headers
    static let contentType = "Content-Type"
    static let contentTypeJSON = "application/json"
    
    // Misc
    static let validImageDomain = "mydomain.bg"
    static let validImageFormat = ".jpg"
}

protocol Requestable {
    var urlRequest: URLRequest? { get }
}

typealias CompletionHandler = (_ error: String, _ data: JSONDictionary?) -> Void

protocol APIRequest {
    func load(requestable: Requestable, completion: @escaping CompletionHandler)
}

enum RequestElement : String {
    case username, password, email, accessToken, getUserInfoParams, setUserInfoParams, objectId
}

protocol RequestInputValidation {
    typealias InputValidationResult = [RequestElement: Bool]
    func isValid() -> InputValidationResult
}

struct RESTRequest : APIRequest {
    func load(requestable: Requestable, completion: @escaping CompletionHandler) {
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        guard let urlRequest = requestable.urlRequest else {
            completion("Bad request object.", nil)
            return
        }

        guard let url = urlRequest.url else {
            completion("Bad request url", nil)
            return
        }
        
        print("Request for \(url.absoluteString) :")
        
        let task = session.dataTask(with: urlRequest, completionHandler: {
        (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let mydata = data else {
                completion("Cannot parse data.", nil)
                return
            }
            
            prettyPrintData(data: mydata)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion("Unable to cast response.", nil)
                return
            }
            
            print("Status \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                completion("HTTP Error: \(httpResponse.statusCode)", nil)
                return
            }
            
            if (mydata.isEmpty) {
                completion("", nil)
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: mydata, options: []),
                let jsonDictionary = jsonObject as? JSONDictionary else {
                completion("Bad json data in response.", nil)
                    return
            }
            
            completion("", jsonDictionary)
        })
        
        task.resume()
    }
}
