//
//  DataSerialization.swift
//  RESTConsumer
//
//  Created by Hristo Tentchev on 9/11/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

// We use protocols to alias types for JSON Values and JSON Dictionaries.

// A dictionary key can be anything convertible to string
protocol JSONDictionaryKey {
    var asString: String { get }
}

// Even the String class itself
extension String : JSONDictionaryKey {
    var asString: String { return self }
}

// This is achieved by making values conform to an empty procotocol:
protocol JSONValue {}

extension Int : JSONValue {}
extension Bool : JSONValue {}
extension String : JSONValue {}
extension Double: JSONValue {}
extension Dictionary : JSONValue {}
extension Array : JSONValue {}

// Note that the keytype here is String and not JSONDictionaryKey.
// (We would need to implement Hashable if we used JSONDictionaryKey,
// becase Dictionary<Key, Value> requires Key to conform to Hashable.

typealias JSONDictionary = [String: Any]
typealias JSONArray = [JSONValue]

// A handy method for accessing our values from dictionaries
extension Dictionary where Key == String, Value: Any {
    func value<V: JSONValue>(forKey: JSONDictionaryKey) -> V? {
        return self[forKey.asString] as? V
    }
}
