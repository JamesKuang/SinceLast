//
//  BitbucketOAuth.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct BitbucketOAuth: OAuthCredentials {
    let service: GitService = .bitbucket
    let authorizationURL = URL(string: "https://bitbucket.org/site/oauth2/authorize")!

    private let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider.shared

    var parameters: [String: String] {
        return ["client_id": keySecretProvider.key,
                "response_type": "code",
        ]
    }
}
