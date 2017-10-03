//
//  Request.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/25/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ error: String, _ data: JSONDictionary?) -> Void

protocol APIRequest {
    associatedtype Model
    
    func load(requestable: Requestable, completion: @escaping (String, Model?) -> Void)
    func modelFromData(data: Data) -> Model?
}

extension APIRequest {
    func load(requestable: Requestable, completion: @escaping (String, Model?) -> Void) {
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
            
            completion("", self.modelFromData(data: mydata))
        })
        
        task.resume()
    }
}

