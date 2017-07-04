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

protocol GithubGraphPaginating {
    static var pageInfo: [String] { get }
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

struct GithubRepositoriesRequest: GithubTypedRequest, GithubGraphTraversing, GithubGraphPaginating {
    typealias ResultType = GithubArrayResult<GithubRepository, GithubRepositoriesRequest>

    let cursor: String?
    let pageSize: Int = 20

    // DEBT: Clean up into objects
    private var repositoriesParams: String {
        if let cursor = cursor {
            return "first: \(pageSize), after:\"\(cursor)\", orderBy: {field: PUSHED_AT, direction: DESC"
        } else {
            return "first: \(pageSize), orderBy: {field: PUSHED_AT, direction: DESC"
        }
    }

    var bodyParameters: [String : Any] {
        return [
            "query": "query { viewer { repositories(\(repositoriesParams)}) { pageInfo { endCursor hasNextPage } edges { node { id name description owner { id login } } } } } }",
        ]
    }

    static var connections: [String] {
        return ["data", "viewer", "repositories", "edges"]
    }

    static var pageInfo: [String] {
        return ["data", "viewer", "repositories", "pageInfo"]
    }
}
