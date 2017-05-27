//
//  OAuth.swift
//  SinceLast
//
//  Created by James Kuang on 5/9/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct OAuth {
    let credentials: OAuthCredentials

    var fullAuthURL: URL {
        guard var components = URLComponents(url: credentials.authorizationURL, resolvingAgainstBaseURL: false) else {
            fatalError("OAuth has bad authorization URL")
        }
        components.queryItems = credentials.parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            fatalError("OAuth parameters cannot be appended as query parameters to URL")
        }
        return url
    }

    init(credentials: OAuthCredentials) {
        self.credentials = credentials
    }
}

protocol OAuthKeySecretProviding {
    var key: String { get }
    var secret: String { get }
}

final class OAuthKeySecretProvider: OAuthKeySecretProviding {
    static let shared = OAuthKeySecretProvider()

    let key: String
    let secret: String

    init() {
        let contents = EnvironmentVariablesReader().read()
        guard let key = contents["Bitbucket.key"] else { fatalError("Missing key in API credentials storage") }
        guard let secret = contents["Bitbucket.secret"] else { fatalError("Missing secret in API credentials storage") }

        self.key = key
        self.secret = secret
    }
}
