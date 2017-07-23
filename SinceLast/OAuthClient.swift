//
//  OAuthClient.swift
//  SinceLast
//
//  Created by James Kuang on 6/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation
import PromiseKit

final class OAuthClient {
    let service: GitService

    private lazy var tokenStorage: TokenStorage = {
        return TokenStorage(service: self.service)
    }()

    private lazy var oAuth: NetworkClient = {
        return NetworkClient(baseURL: self.service.oAuthBaseURL, configuration: .ephemeral)
    }()

    init(service: GitService) {
        self.service = service
    }

    func authorize(code: String) -> Promise<OAuthAccessToken> {
        let sendPromise: Promise<OAuthAccessToken>
        switch service {
        case .github:
            let request = GithubAccessTokenRequest(code: code)
            sendPromise = oAuth.send(request: request)
        case .bitbucket:
            let request = BitbucketAccessTokenRequest(grantType: .authorization(code: code))
            sendPromise = oAuth.send(request: request)
        }

        return sendPromise.then { accessToken -> OAuthAccessToken in
            self.tokenStorage.store(token: accessToken)
            return accessToken
        }
    }

    func refreshAuthToken() throws -> Promise<OAuthAccessToken> {
        guard let token = tokenStorage.token?.refreshToken else {
            print("Attempting to get a new token, but missing refresh token.")
            throw NilError()
        }

        let sendPromise: Promise<OAuthAccessToken>
        switch service {
        case .github:
            throw UnavailableError("Can't refresh Github tokens: they never expire.")
        case .bitbucket:
            let request = BitbucketAccessTokenRequest(grantType: .refresh(token: token))
            sendPromise = oAuth.send(request: request)
        }

        return sendPromise.then { accessToken -> OAuthAccessToken in
            self.tokenStorage.store(token: accessToken)
            return accessToken
        }
    }
}
