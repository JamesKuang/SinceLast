//
//  OAuthCredentials.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol OAuthCredentials {
    /// This is the raw URL. It should not be used directly.
    var authorizationURL: URL { get }
    var parameters: [String: String] { get }
}

struct BitbucketOAuth: OAuthCredentials {
    let authorizationURL = URL(string: "https://bitbucket.org/site/oauth2/authorize")!
    let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider()

    var parameters: [String: String] {
        return ["client_id": keySecretProvider.key,
                "response_type": "code",
        ]
    }
}
