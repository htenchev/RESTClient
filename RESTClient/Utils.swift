//
//  Utils.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/28/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

func prettyPrintData(data: Data) {
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
        print("jsonObject(with::) failed")
        return
    }
    
    guard let prettyDataObj = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
        print("data(withJSONObject:: failed.")
        return
    }
    
    if let prettyJsonString = String(data: prettyDataObj, encoding: String.Encoding.utf8) {
        print("Data:\n\(prettyJsonString)")
    } else {
        print("Cannot convert JSON.")
        return
    }
}



