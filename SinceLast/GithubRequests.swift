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

struct GithubCommitsRequest: GithubTypedRequest, GithubGraphTraversing, GithubGraphPaginating {
    typealias ResultType = GithubArrayResult<GithubRepository, GithubCommitsRequest>

    let repositoryName: String
    let authorID: String
    let since: Date

    let refPrefix = "refs/heads/"

    var formattedSinceDate: String {
        // TODO: fix timestamp format
        return ISO8601DateFormatter.string(from: since, timeZone: TimeZone.current, formatOptions: [])
    }

    var bodyParameters: [String : Any] {
        return [
            "query": "query { viewer { repository(name: \"\(repositoryName)\") { refs(last: 5, refPrefix: \"\(refPrefix)\") { pageInfo { endCursor hasNextPage } edges { node { name target { ... on Commit { history(first: 20, author: {id: \"\(authorID)\"}, since: \"\(formattedSinceDate)\") { edges { node { message committedDate } } } } } } } } } } }",
        ]
    }

    init(repositoryName: String, authorID: String, daysAgo: Int = 3) {
        self.repositoryName = repositoryName
        self.authorID = authorID
        guard let since = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else { fatalError("Unable to create a date from calendar") }
        self.since = since
    }

    static var connections: [String] {
        return ["data", "viewer", "repository", "refs", "edges"]
    }

    static var pageInfo: [String] {
        return ["data", "viewer", "repository", "refs", "pageInfo"]
    }
}

//{
//    viewer {
//        repository(name: "SinceLast") {
//            refs(last: 5, refPrefix: "refs/heads/") {
//                edges {
//                    node {
//                        name
//                        target {
//                            ... on Commit {
//                                history(first: 20, author: {id: "MDQ6VXNlcjEyMzE1MTM="}, since: "2017-07-01T00:00:00+00:00") {
//                                    edges {
//                                        node {
//                                            message
//                                            committedDate
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
