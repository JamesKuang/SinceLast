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

    private lazy var main: NetworkClient = {
        let configuration = URLSessionConfiguration.default
        if let token = TokenStorage(service: self.service).token {
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
        return main.send(request: request)
    }

    func authorize(code: String) -> Promise<OAuthAccessToken> {
        let request = OAuthAccessTokenRequest(code: code)
        return oAuth.send(request: request).then { (accessToken) -> OAuthAccessToken in
            let tokenStorage = TokenStorage(service: self.service)
            tokenStorage.store(token: accessToken)
            return accessToken
        }
    }
}
