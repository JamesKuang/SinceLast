//
//  OAuth.swift
//  SinceLast
//
//  Created by James Kuang on 5/9/17.
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
    let secretProvider: OAuthSecretProviding = OAuthSecretProvider()

    var parameters: [String: String] {
        return ["client_id": secretProvider.clientId,
                "response_type": "code",
        ]
    }
}

protocol OAuthSecretProviding {
    var clientId: String { get }
}

struct OAuthSecretProvider: OAuthSecretProviding {
    let storage: PlistReader = PlistReader(fileName: "OAuth")

    var clientId: String {
        let contents = storage.read()
        guard let clientId = contents.value(forKeyPath: "Bitbucket.clientId") as? String
            else { fatalError("Missing clientId in Plist") }
        return clientId
    }
}

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
