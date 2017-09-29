//
//  Model.swift
//  RESTClient
//
//  Created by Hristo Tentchev on 9/26/17.
//  Copyright © 2017 Tumba Solutions. All rights reserved.
//

import Foundation
import UIKit

struct UserAvatar {
    var url: String = ""
    
    init(with json: JSONDictionary) {
        if let urlString: String = json.value(forKey: Constants.avatarURLKey) {
            url = urlString
        }
    }
    
    var isValid: Bool {
        return !url.isEmpty && url.contains(Constants.validImageDomain) && url.contains(Constants.validImageFormat)
    }
}
