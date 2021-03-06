//
//  BitbucketRequests.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct BitbucketUserRequest: TypedRequest {
    typealias ResultType = BitbucketUser

    let path = "/2.0/user"
    let queryParameters: [String: String] = [:]
}

struct BitbucketRepositoriesRequest: TypedRequest {
    typealias ResultType = BitbucketPaginatedResult<BitbucketRepository>

    let uuid: String
    let page: Int

    var path: String {
        return "/2.0/repositories/\(uuid)"
    }

    var queryParameters: [String: String] {
        guard page > 1 else { return [:] }
        return ["page": String(page)]
    }

    init(uuid: String, page: Int = 1) {
        self.uuid = uuid
        self.page = page
    }
}

struct BitbucketTeamsRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<BitbucketUser>

    let path = "/2.0/teams"

    let queryParameters: [String: String] = ["role": "contributor"]
}

// Not used, figure out if this is needed.
struct BitbucketTeamRepositoriesRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<BitbucketRepository>

    let uuid: String

    var path: String {
        return "/2.0/teams/\(uuid)/repositories"
    }

    let queryParameters: [String: String] = [:]
}

struct BitbucketCommitsRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<BitbucketCommit>

    let uuid: String
    let repositorySlug: String

    let queryParameters: [String: String] = [:]

    var path: String {
        return "/2.0/repositories/\(uuid)/\(repositorySlug)/commits"
    }
}

struct BitbucketPullRequestsRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<BitbucketPullRequest>

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

struct BitbucketBranchesRequest: TypedRequest {
    typealias ResultType = BitbucketArrayResult<BitbucketBranch>

    let uuid: String
    let repositorySlug: String

    var queryParameters: [String: String] {
        let sort = "-target.date"
        return ["sort": sort]
    }

    var path: String {
        return "/2.0/repositories/\(uuid)/\(repositorySlug)/refs/branches"
    }
}
