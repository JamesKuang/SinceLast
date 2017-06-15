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
    enum Service {
        case github
        case bitbucket

        fileprivate var key: String {
            switch self {
            case .github: return "Github.key"
            case .bitbucket: return "Bitbucket.key"
            }
        }

        fileprivate var secret: String {
            switch self {
            case .github: return "Github.secret"
            case .bitbucket: return "Bitbucket.secret"
            }
        }
    }

    static let shared = OAuthKeySecretProvider(service: .bitbucket)

    let key: String
    let secret: String

    init(service: Service) {
        let contents = PlistReader(fileName: "OAuth").read()
        guard let key = contents.value(forKeyPath: service.key) as? String
            else { fatalError("Missing key in Plist") }
        guard let secret = contents.value(forKeyPath: service.secret) as? String
            else { fatalError("Missing secret in Plist") }

        self.key = key
        self.secret = secret
    }
}
