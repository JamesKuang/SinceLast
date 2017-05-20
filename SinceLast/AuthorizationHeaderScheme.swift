//
//  AuthorizationHeaderScheme.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum AuthorizationHeaderScheme {
    case basic(user: String, password: String)
    case bearer(token: String)

    var key: String {
        return "Authorization"
    }

    var value: String {
        switch self {
        case .basic(let user, let password):
            let userAndPassword = "\(user):\(password)"
            guard let data = userAndPassword.data(using: .utf8) else { fatalError("Must be convertible to UTF8 encoding") }
            let encoded = data.base64EncodedString()
            return "Basic \(encoded)"
        case .bearer(let token):
            return "Bearer \(token)"
        }
    }

    var keyValuePair: [String: String] {
        return [key: value]
    }

    init(token: OAuthAccessToken) {
        self = .bearer(token: token.token)
    }
}
