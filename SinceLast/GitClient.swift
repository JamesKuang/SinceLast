//
//  GitClient.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation
import PromiseKit

protocol GitClientRequiring {
    var gitClient: GitClient { get }
}

final class GitClient {
    let service: GitService

    private lazy var tokenStorage: TokenStorage = {
        return TokenStorage(service: self.service)
    }()

    private lazy var main: NetworkClient = {
        let configuration = self.makeConfiguration(with: self.tokenStorage)
        return NetworkClient(baseURL: self.service.apiBaseURL, configuration: configuration)
    }()

    init(service: GitService) {
        self.service = service
    }

    func send<RequestType, OutputType>(request: RequestType) -> Promise<OutputType> where RequestType: TypedRequest, RequestType.ResultType == OutputType {
        return main
            .send(request: request)
            .recover(execute: { error -> Promise<OutputType> in
                guard error is OAuthTokenExpiredError else { throw error }
                let oAuthClient = OAuthClient(service: self.service)
                return try oAuthClient.refreshAuthToken().then(execute: { token -> Promise<OutputType> in
                    let newConfiguration = self.makeConfiguration(with: self.tokenStorage)
                    self.main.renewSession(with: newConfiguration)
                    return self.main.send(request: request)
                })
            })
    }

    private func makeConfiguration(with tokenStorage: TokenStorage) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        if let token = tokenStorage.token {
            let scheme = AuthorizationHeaderScheme(token: token)
            configuration.httpAdditionalHeaders = scheme.keyValuePair
        }
        return configuration
    }
}

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
            // TODO: Needs to be tested, now sure how to refresh
            let request = GithubAccessTokenRequest(code: token)
            sendPromise = oAuth.send(request: request)
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
