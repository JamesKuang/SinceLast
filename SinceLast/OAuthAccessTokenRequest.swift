//
//  OAuthAccessTokenRequest.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct OAuthAccessTokenRequest: Request {
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
        return [
            scheme.key: scheme.value,
        ]
    }
}

struct RepositoriesRequest: Request, GitServiceRequiring {
    let path = "/2.0/repositories"

    let queryParameters: [String : String] = [:]

    let gitService: GitService

    var additionalHeaders: [String : String] {
        let tokenStorage = TokenStorage(service: gitService)
        let scheme: AuthorizationHeaderScheme = .bearer(token: tokenStorage.token!.token) // FIXME: client should inject this header, and handle expiration
        return [
            scheme.key: scheme.value,
        ]
    }
}
