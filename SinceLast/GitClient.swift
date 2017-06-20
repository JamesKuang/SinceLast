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
