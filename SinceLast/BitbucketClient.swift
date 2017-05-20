//
//  BitbucketClient.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class BitbucketClient: GitClient {
    let service: GitService = .bitbucket

    private lazy var main: NetworkClient = {
        let configuration = URLSessionConfiguration()
        if let token = TokenStorage(service: self.service).token {
            let scheme = AuthorizationHeaderScheme(token: token)
            configuration.httpAdditionalHeaders = scheme.keyValuePair
        }

        return NetworkClient(baseURL: self.service.apiBaseURL, configuration: configuration)
    }()

    private lazy var oAuth: NetworkClient = {
        return NetworkClient(baseURL: self.service.oAuthBaseURL)
    }()

    func send(request: Request, completion: @escaping (Result<[String : Any]>) -> ()) {
        return main.send(request: request, completion: completion)
    }

    func authorize(code: String, success: (() -> Void)?) {
        let request = OAuthAccessTokenRequest(code: code)
        oAuth.send(request: request, completion: { result in
            switch result {
            case .success(let json):
                guard let token = OAuthAccessToken(json: json) else { return }
                let tokenStorage = TokenStorage(service: self.service)
                tokenStorage.store(token: token)
                DispatchQueue.main.async {
                    success?()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
