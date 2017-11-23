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

protocol Chainer {
    func add(_ operation: API)
}

typealias RequestCompletion = (OperationResult?, RequestError?) -> Bool
typealias ChainedRequestCompletion = (OperationResult?, RequestError?, Chainer) -> Bool

protocol RequestPerformer {
    func modelFromData(data: Data) -> OperationResult?
    func execute(completion: @escaping RequestCompletion)
}

extension API : RequestPerformer {
    // Convert data to JSON an let the ModelType classes handle parsing
    func modelFromData(data: Data) -> OperationResult? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonValue = jsonObject as? JSONDictionary else {
                return nil//.error("Bad json in modelFromData(:_:_)")
        }
        
        switch self {
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
    
    func execute(completion: @escaping RequestCompletion) {
        guard let urlRequest = self.urlRequest else {
            _ = completion(nil, RequestError(description: "Bad url request"))
            return
        }
        
        guard let url = urlRequest.url else {
            _ = completion(nil, RequestError(description: "Bad url"))
            return
        }
        
        print("Request for \(url.absoluteString) :")
        
        let task = API.urlSession.dataTask(with: urlRequest, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let mydata = data else {
                _ = completion(nil, RequestError(description: "Cannot parse data."))
                return
            }
            
            prettyPrintData(data: mydata)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                _ = completion(nil, RequestError(description: "Unable to cast response."))
                return
            }
            
            print("Status \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                _ = completion(nil, RequestError(description: "HTTP Error: \(httpResponse.statusCode)"))
                return
            }
            
            guard let result = self.modelFromData(data: mydata) else {
                _ = completion(nil, RequestError(description: "sdfsdf"))
                return
            }
            
            _ = completion(result, nil)
        })
        
        task.resume()
    }
    
    private static let urlSession = { () -> URLSession in
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = [Constants.contentType: Constants.contentTypeJSON]
        return URLSession(configuration: configuration)
    }()
}

class RequestChain : Chainer {
    typealias FirstCompletion = (Chainer) -> ()
    
    func add(_ operation: API) {
        self.operation = operation
    }
    
    func firstly(completion: @escaping FirstCompletion) -> RequestChain {
        firstCompletion = completion
        return self
    }
    
    func then(completion: @escaping ChainedRequestCompletion) -> RequestChain {
        completions.append(completion)
        return self
    }
    
    func reset() {
        completions.removeAll()
        operation = nil
        firstCompletion = { _ in }
    }
    
    private func executeChain() {
        guard let currOperation = operation else {
            return
        }
        
        let outerCompletion: RequestCompletion = { [weak self] result, err in
            guard let this = self else {
                return false
            }
            
            let userCompletion = this.completions.removeFirst()
            let result = userCompletion(result, err, this)
            this.executeChain()
            
            return result
        }
        
        currOperation.execute(completion: outerCompletion)
    }
    
    func execute() {
        firstCompletion(self)
        executeChain()
    }

    private var firstCompletion: FirstCompletion = { _ in }
    private var completions: [ChainedRequestCompletion] = []
    private var operation: API?
}

