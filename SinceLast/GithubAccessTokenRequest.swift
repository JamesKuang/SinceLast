//
//  GithubAccessTokenRequest.swift
//  SinceLast
//
//  Created by James Kuang on 6/16/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubAccessTokenRequest: TypedRequest {
    typealias ResultType = OAuthAccessToken

    let method: RequestMethod = .POST

    let credentials: OAuthCredentials = GithubOAuth()
    let code: String

    var path: String {
        return credentials.accessTokenPath
    }

    var additionalHeaders: [String : String] {
        return ["Accept": "application/json"]
    }

    var queryParameters: [String: String] {
        return [
            "client_id": credentials.keySecretProvider.key,
            "client_secret": credentials.keySecretProvider.secret,
            "code": code,
        ]
    }
}
