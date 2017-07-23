//
//  GithubOAuth.swift
//  SinceLast
//
//  Created by James Kuang on 5/26/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubOAuth: OAuthCredentials {
    let authorizationURL = URL(string: "https://github.com/login/oauth/authorize")!

    let accessTokenPath = "/login/oauth/access_token"

    let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider.github

    var parameters: [String: String] {
        return ["client_id": keySecretProvider.key,
                "allow_signup": "false",
        ]
    }
}
