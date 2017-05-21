//
//  OAuthAccessTokenRequest.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct OAuthAccessTokenRequest: TypedRequest {
    typealias ResultType = OAuthAccessToken

    let method: RequestMethod = .POST
    let path = "/site/oauth2/access_token"

    let code: String
    private let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider()

    var queryParameters: [String: String] {
        return [
            "grant_type": "authorization_code",
            "code": code,
        ]
    }

    var additionalHeaders: [String : String] {
        let scheme: AuthorizationHeaderScheme = .basic(user: keySecretProvider.key, password: keySecretProvider.secret)
        return scheme.keyValuePair
    }
}
