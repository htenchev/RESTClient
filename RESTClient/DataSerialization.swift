//
//  DataSerialization.swift
//  RESTConsumer
//
//  Created by Hristo Tentchev on 9/11/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

protocol JSONDictionaryKey {
    var asString: String { get }
}

extension String : JSONDictionaryKey {
    var asString: String { return self }
}

protocol JSONDictionaryValue {}

extension Int : JSONDictionaryValue {}
extension Bool : JSONDictionaryValue {}
extension String : JSONDictionaryValue {}
extension Double: JSONDictionaryValue {}
extension Dictionary : JSONDictionaryValue {}
extension Array : JSONDictionaryValue {}

extension Dictionary where Key == String, Value: Any {
    func value<V: JSONDictionaryValue>(forKey: JSONDictionaryKey) -> V? {
        return self[forKey.asString] as? V
    }
}
