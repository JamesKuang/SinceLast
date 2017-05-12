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
    let secretProvider: OAuthSecretProviding

    var parameters: [String: String] {
        return ["client_id": secretProvider.clientId,
                "response_type": "code",
        ]
    }

    init(secretProvider: OAuthSecretProviding = PlistReader(fileName: "OAuth")) {
        self.secretProvider = secretProvider
    }
}

protocol OAuthSecretProviding {
    var clientId: String { get }
}

final class PlistReader {
    let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func read() -> NSDictionary {
        guard let plistPath = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let contents = NSDictionary(contentsOfFile: plistPath)
            else { fatalError("No Plist found") }
        return contents
    }
}

extension PlistReader: OAuthSecretProviding {
    var clientId: String {
        let contents = read()
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
