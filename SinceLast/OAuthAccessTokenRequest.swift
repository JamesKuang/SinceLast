//
//  OAuthAccessTokenRequest.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct OAuthAccessTokenRequest: TypedRequest {
    typealias ResultType = OAuthAccessToken

    enum GrantType {
        case authorization(code: String)
        case refresh(token: String)

        var queryParameters: [String: String] {
            switch self {
            case .authorization(let code):
                return [
                    "grant_type": "authorization_code",
                    "code": code,
                ]
            case .refresh(let token):
                return [
                    "grant_type": "refresh_token",
                    "refresh_token": token,
                ]
            }
        }
    }

    let method: RequestMethod = .POST
    let path = "/site/oauth2/access_token"

    let grantType: GrantType
    private let keySecretProvider: OAuthKeySecretProviding = OAuthKeySecretProvider.shared

    var queryParameters: [String: String] {
        return grantType.queryParameters
    }

    var additionalHeaders: [String : String] {
        let scheme: AuthorizationHeaderScheme = .basic(user: keySecretProvider.key, password: keySecretProvider.secret)
        return scheme.keyValuePair
    }
}
