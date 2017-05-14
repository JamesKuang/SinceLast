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
