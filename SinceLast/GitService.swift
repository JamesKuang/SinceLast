//
//  GitService.swift
//  SinceLast
//
//  Created by James Kuang on 5/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

enum GitService {
    case github
    case bitbucket

    var name: String {
        switch self {
        case .github: return "Github"
        case .bitbucket: return "Bitbucket"
        }
    }

    var apiBaseURL: String {
        switch self {
        case .github: return "https://api.github.com/graphql"
        case .bitbucket: return "https://api.bitbucket.org"
        }
    }

    var oAuthBaseURL: String {
        switch self {
        case .github: return "http://github.com"
        case .bitbucket: return "https://bitbucket.org"
        }
    }

    var logoImage: UIImage {
        switch self {
        case .github: return #imageLiteral(resourceName: "github_logo")
        case .bitbucket: return #imageLiteral(resourceName: "bitbucket_logo")
        }
    }

    var oAuthCredentials: OAuthCredentials {
        switch self {
        case .github: return GithubOAuth()
        case .bitbucket: return BitbucketOAuth()
        }
    }

    var isSupported: Bool {
        switch self {
        case .github: return true
        case .bitbucket: return true
        }
    }

    init?(serviceName: String) {
        switch serviceName {
        case "github": self = .github
        case "bitbucket": self = .bitbucket
        default: return nil
        }
    }

    func configureSessionConfiguration(_ configuration: URLSessionConfiguration) {
        switch self {
        case .github:
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        case .bitbucket:
            break
        }
    }
}

extension GitService {
    func userRequest<T: User>() -> AnyJSONRequest<T> {
        switch self {
        case .github: return AnyJSONRequest(GithubUserRequest())
        case .bitbucket: return AnyJSONRequest(BitbucketUserRequest())
        }
    }

    func repositoriesRequest<T: JSONInitializable>(page: Pagination, ownerUUID: String) -> AnyJSONRequest<T> {
        switch self {
        case .github:
            return AnyJSONRequest(GithubRepositoriesRequest(cursor: page.cursorPage))
        case .bitbucket:
            guard let next = page.integerPage else { fatalError("Bitbucket requires integer pagination") }
            return AnyJSONRequest(BitbucketRepositoriesRequest(uuid: ownerUUID, page: next))
        }
    }
}
