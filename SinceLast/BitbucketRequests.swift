//
//  BitbucketRequests.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct BitbucketArrayResult<T: JSONInitializable>: JSONInitializable {
    let objects: [T]

    init(json: JSON) throws {
        guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
        self.objects = try values.flatMap { try T(json: $0) }
    }
}

struct BitbucketUserRequest: TypedRequest {
    typealias ResultType = User

    let path = "/2.0/user"
    let queryParameters: [String: String] = [:]
}

struct BitbucketRepositoriesRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<Repository>

    let uuid: String

    var path: String {
        return "/2.0/repositories/\(uuid)"
    }

    let queryParameters: [String: String] = [:]
}

struct BitbucketTeamsRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<User>

    let path = "/2.0/teams"

    let queryParameters: [String: String] = ["role": "contributor"]
}

// Not used, figure out if this is needed.
struct BitbucketTeamRepositoriesRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<Repository>

    let uuid: String

    var path: String {
        return "/2.0/teams/\(uuid)/repositories"
    }

    let queryParameters: [String: String] = [:]
}

struct BitbucketCommitsRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<Commit>

    let uuid: String
    let repositorySlug: String

    let queryParameters: [String: String] = [:]

    var path: String {
        return "/2.0/repositories/\(uuid)/\(repositorySlug)/commits"
    }
}

struct BitbucketPullRequestsRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<PullRequest>

    let uuid: String
    let repositorySlug: String
    let filterUserName: String

    var queryParameters: [String: String] {
        let state = "OPEN"
        let query = "state = \"\(state)\" AND reviewers.username = \"\(filterUserName)\""
        return ["q": query]
    }

    var path: String {
        return "/2.0/repositories/\(uuid)/\(repositorySlug)/pullrequests"
    }
}
