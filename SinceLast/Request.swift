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
    var bodyParameters: [String: Any] { get }
    var parser: RequestParser { get }
}

extension Request {
    var queryParameters: [String: String] {
        return [:]
    }

    var bodyParameters: [String: Any] {
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

    var bodyParameters: [String : Any] {
        return [
            "grant_type": "authorization_code",
            "client_id": keySecretProvider.key,
            "client_secret": keySecretProvider.secret,
            "code": code,
        ]
    }
}
