//
//  GithubRequests.swift
//  SinceLast
//
//  Created by James Kuang on 6/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol GithubTypedRequest: TypedRequest {}

protocol GithubGraphTraversing {
    static var connections: [String] { get }
}

extension GithubTypedRequest {
    var method: RequestMethod {
        return .POST
    }

    var contentType: ContentType {
        return .json
    }

    var path: String {
        return ""
    }

    var queryParameters: [String : String] {
        return [:]
    }
}

struct GithubUserRequest: GithubTypedRequest {
    typealias ResultType = GithubUser

    var bodyParameters: [String : Any] {
        return [
            "query": "query { viewer { login id }}",
        ]
    }
}

struct GithubRepositoriesRequest: GithubTypedRequest, GithubGraphTraversing {
    typealias ResultType = GithubArrayResult<GithubRepository, GithubRepositoriesRequest>

    let page: Int

    var bodyParameters: [String : Any] {
        return [
            "query": "query { viewer { repositories(first: 50, orderBy: {field: PUSHED_AT, direction: DESC}) { edges { node { id name description owner { id login } } } } } }",
        ]
    }

    static var connections: [String] {
        return ["data", "viewer", "repositories", "edges"]
    }
}
