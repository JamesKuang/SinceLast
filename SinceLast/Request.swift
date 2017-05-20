//
//  Request.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum RequestMethod: String {
    case GET
    case POST
}

protocol Request {
    var method: RequestMethod { get }
    var path: String { get }
    var queryParameters: [String: String] { get }
    var additionalHeaders: [String: String] { get }
    var parser: RequestParser { get }
}

extension Request {
    var additionalHeaders: [String: String] {
        return [:]
    }

    var parser: RequestParser {
        return JSONParser()
    }
}

struct OAuthAccessTokenRequest: Request {
    let method: RequestMethod = .POST
    let path = "/site/oauth2/access_token"

    let code: String
    let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider()

    var queryParameters: [String: String] {
        return [
            "grant_type": "authorization_code",
            "code": code,
        ]
    }

    var additionalHeaders: [String : String] {
        let userAndPassword = "\(keySecretProvider.key):\(keySecretProvider.secret)"
        guard let data = userAndPassword.data(using: .utf8) else { fatalError("Must be convertible to UTF8 encoding") }
        let encoded = data.base64EncodedString()

        return [
            "Authorization": "Basic \(encoded)",
        ]
    }
}
