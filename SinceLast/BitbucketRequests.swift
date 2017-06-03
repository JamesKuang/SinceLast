//
//  BitbucketRequests.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct BitbucketUserRequest: TypedRequest {
    typealias ResultType = User

    let path = "/2.0/user"
    let queryParameters: [String: String] = [:]
}

struct BitbucketRepositoriesRequest: TypedRequest {
    typealias ResultType = RepositoriesResult

    let uuid: String

    var path: String {
        return "/2.0/repositories/\(uuid)"
    }

    let queryParameters: [String: String] = [:]

    struct RepositoriesResult: JSONInitializable {
        let repositories: [Repository]

        init(json: JSON) throws {
            guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
            self.repositories = try values.flatMap { try Repository(json: $0) }
        }
    }
}

struct BitbucketTeamsRequest: TypedRequest {
    typealias ResultType = TeamsResult

    let path = "/2.0/teams"

    let queryParameters: [String: String] = ["role": "contributor"]

    struct TeamsResult: JSONInitializable {
        let teams: [User]

        init(json: JSON) throws {
            guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
            self.teams = try values.flatMap { try User(json: $0) }
        }
    }
}

// Not used, figure out if this is needed.
struct BitbucketTeamRepositoriesRequest: TypedRequest {
    typealias ResultType = RepositoriesResult

    let uuid: String

    var path: String {
        return "/2.0/teams/\(uuid)/repositories"
    }

    let queryParameters: [String: String] = [:]

    struct RepositoriesResult: JSONInitializable {
        let repositories: [Repository]

        init(json: JSON) throws {
            guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
            self.repositories = try values.flatMap { try Repository(json: $0) }
        }
    }
}

struct BitbucketCommitsRequest: TypedRequest {
    typealias ResultType = CommitsResult

    let uuid: String
    let repositorySlug: String

    let queryParameters: [String: String] = [:]

    var path: String {
        return "/2.0/repositories/\(uuid)/\(repositorySlug)/commits"
    }

    struct CommitsResult: JSONInitializable {
        let commits: [Commit]

        init(json: JSON) throws {
            guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
            self.commits = try values.flatMap { try Commit(json: $0) }
        }
    }
}

struct BitbucketPullRequestsRequest: TypedRequest {
    typealias ResultType = PullRequestsResult

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

    struct PullRequestsResult: JSONInitializable {
        let pullRequests: [PullRequest]

        init(json: JSON) throws {
            guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
            self.pullRequests = try values.flatMap { try PullRequest(json: $0) }
        }
    }
}
