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

    func send(request: Request, completion: @escaping (Result<[String : Any]>) -> ()) {
        return client.send(request: request, completion: completion)
    }
}
