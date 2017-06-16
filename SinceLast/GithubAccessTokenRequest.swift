//
//  GithubAccessTokenRequest.swift
//  SinceLast
//
//  Created by James Kuang on 6/16/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubAccessTokenRequest: TypedRequest {
    typealias ResultType = OAuthAccessToken

//    enum GrantType {
//        case authorization(code: String)
//        case refresh(token: String)
//
//        var queryParameters: [String: String] {
//            switch self {
//            case .authorization(let code):
//                return [
//                    "code": code,
//                ]
//            case .refresh(let token):
//                return [
//                    "refresh_token": token,
//                ]
//            }
//        }
//    }

    let method: RequestMethod = .POST

    let credentials: OAuthCredentials = BitbucketOAuth()
    let code: String

    var path: String {
        return credentials.accessTokenPath
    }

    var queryParameters: [String: String] {
        return [
            // TODO: test this
            "client_id": credentials.keySecretProvider.key,
            "client_secret": credentials.keySecretProvider.secret,
            "code": code,
        ]
    }
}
