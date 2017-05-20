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
}

protocol GitServiceAuthorizing {
    var service: GitService { get }
    var oAuthCredentials: OAuthCredentials { get }
}

struct BitbucketAuthorization: GitServiceAuthorizing {
    let service: GitService = .bitbucket
    let oAuthCredentials: OAuthCredentials = BitbucketOAuth()
}
