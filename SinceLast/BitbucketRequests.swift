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

    let userName: String

    var path: String {
        return "/2.0/repositories/\(userName)"
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

    let userName: String
    let repositorySlug: String

    let queryParameters: [String: String] = [:]

    var path: String {
        return "/2.0/repositories/\(userName)/\(repositorySlug)/commits"
    }

    struct CommitsResult: JSONInitializable {
        let commits: [Commit]

        init(json: JSON) throws {
            guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
            self.commits = try values.flatMap { try Commit(json: $0) }
        }
    }
}
