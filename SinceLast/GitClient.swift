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
        let configuration = URLSessionConfiguration.default
        if let token = self.tokenStorage.token {
            let scheme = AuthorizationHeaderScheme(token: token)
            configuration.httpAdditionalHeaders = scheme.keyValuePair
        }

        return NetworkClient(baseURL: self.service.apiBaseURL, configuration: configuration)
    }()

    private lazy var oAuth: NetworkClient = {
        return NetworkClient(baseURL: self.service.oAuthBaseURL, configuration: .ephemeral)
    }()

    init(service: GitService) {
        self.service = service
    }

    func send<RequestType, OutputType>(request: RequestType) -> Promise<OutputType> where RequestType: TypedRequest, RequestType.ResultType == OutputType {
        return main
            .send(request: request)
            .recover(execute: { error -> Promise<OutputType> in
                guard error is OAuthTokenExpiredError else { throw error }
                return try self.refreshAuthToken().then(execute: { token -> Promise<OutputType> in
                    self.tokenStorage.store(token: token)
                    return self.main.send(request: request)
                })
            })
    }

    func authorize(code: String) -> Promise<OAuthAccessToken> {
        let request = OAuthAccessTokenRequest(grantType: .authorization(code: code))
        return oAuth.send(request: request).then { (accessToken) -> OAuthAccessToken in
            self.tokenStorage.store(token: accessToken)
            return accessToken
        }
    }

    private func refreshAuthToken() throws -> Promise<OAuthAccessToken> {
        guard let token = tokenStorage.token?.refreshToken else { throw NilError() }
        let request = OAuthAccessTokenRequest(grantType: .refresh(token: token))
        return oAuth.send(request: request).then { (accessToken) -> OAuthAccessToken in
            self.tokenStorage.store(token: accessToken)
            return accessToken
        }
    }
}
