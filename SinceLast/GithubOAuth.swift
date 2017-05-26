//
//  GithubOAuth.swift
//  SinceLast
//
//  Created by James Kuang on 5/26/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

// TODO: NYI

struct GithubOAuth: OAuthCredentials {
    let service: GitService = .github
    let authorizationURL = URL(string: "https://api.github.com/authorizations")!

    private let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider()

    var parameters: [String: String] {
        return ["client_id": keySecretProvider.key,
                "response_type": "code",
        ]
    }
}
