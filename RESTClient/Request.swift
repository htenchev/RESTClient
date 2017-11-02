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
    case error(String)
}

// The APIRequest protocol: those, who conform to it can load data by
// feeding the load function a requestable and a callback, in which they
// can handle request results.
// The modelFromData function returns a wrapped instance of an object,
// representing a type in the app logic (a model object).
protocol APIRequest {
    func load(urlSession: URLSession, requestable: Requestable, completion: @escaping (OperationResult) -> Void)
    func modelFromData(data: Data, operation: API) -> OperationResult
}

// The default implementation of load simply performs the request, generated by requestable
// and calls the completion with the wrapped result.
extension APIRequest {
    func load(urlSession: URLSession, requestable: Requestable, completion: @escaping (OperationResult) -> Void) {
        guard let urlRequest = requestable.urlRequest else {
            completion(.error("Bad url request"))
            return
        }

        guard let url = urlRequest.url else {
            completion(.error("Bad url"))
            return
        }
        
        print("Request for \(url.absoluteString) :")

        let task = urlSession.dataTask(with: urlRequest, completionHandler: {
        (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let mydata = data else {
                completion(.error("Cannot parse data."))
                return
            }
            
            prettyPrintData(data: mydata)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.error("Unable to cast response."))
                return
            }
            
            print("Status \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                completion(.error("HTTP Error: \(httpResponse.statusCode)"))
                return
            }
            
            if (mydata.isEmpty) {
                completion(.error("Empty data"))
            }
            
            completion(self.modelFromData(data: mydata, operation: requestable.operation))
        })
        
        task.resume()
    }
}

struct RESTRequest : APIRequest {
    public init(_ requestable: Requestable) {
        self.requestable = requestable
    }
    
    // Convert data to JSON an let the ModelType classes handle parsing
    func modelFromData(data: Data, operation: API) -> OperationResult {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonValue = jsonObject as? JSONValue else {
                return .error("Bad json in modelFromData(:_:_)")
        }
        
        switch operation {
        case .login:
            return OperationResult.login(LoginResult(data: jsonValue))
        case .register:
            return OperationResult.register(RegistrationResult(data: jsonValue))
        case .logout:
            return OperationResult.logout(LogoutResult(data: jsonValue))
        case .getUserAvatar:
            return OperationResult.setAvatar(SetAvatarResult(data: jsonValue))
        case .setUserAvatar:
            return OperationResult.getAvatar(GetAvatarResult(data: jsonValue))
        }
    }
    
    func execute(completion: @escaping (OperationResult) -> Void) {
        load(urlSession: RESTRequest.urlSession, requestable: requestable, completion: completion)
    }
    
    private let requestable: Requestable
    static let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
}
