//
//  GitService.swift
//  SinceLast
//
//  Created by James Kuang on 5/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum GitService {
    case bitbucket

    var name: String {
        switch self {
        case .bitbucket: return "Bitbucket"
        }
    }

    private var client: NetworkClient {
        switch self {
        case .bitbucket: return SharedNetworkClient.bitbucket
        }
    }

    private var oAuth: NetworkClient {
        switch self {
        case .bitbucket: return SharedNetworkClient.oAuth
        }
    }

    func send(request: Request, completion: @escaping (Result<[String : Any]>) -> ()) {
        return client.send(request: request, completion: completion)
    }

    func authorize(code: String, success: (() -> Void)?) {
        let request = OAuthAccessTokenRequest(code: code)
        oAuth.send(request: request, completion: { result in
            switch result {
            case .success(let json):
                guard let token = OAuthAccessToken(json: json) else { return }
                let tokenStorage = TokenStorage(service: self)
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

protocol GitServiceRequiring {
    var gitService: GitService { get }
}
