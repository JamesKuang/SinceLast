//
//  Branch.swift
//  SinceLast
//
//  Created by James Kuang on 6/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol Branch: JSONInitializable, UUIDEquatable {
    var name: String { get }
    var targetHash: String { get }
}

// MARK: - BitbucketBranch

struct BitbucketBranch: Branch {
    let name: String
    let targetHash: String
}

extension BitbucketBranch: JSONInitializable {
    init(json: JSON) throws {
        guard let name = json["name"] as? String,
            let target = json["target"] as? JSON,
            let targetHash = target["hash"] as? String
            else { throw JSONParsingError() }

        self.name = name
        self.targetHash = targetHash
    }
}

extension BitbucketBranch: UUIDEquatable {
    var uuid: String {
        return targetHash
    }
}

// MARK: - GithubBranch

struct GithubBranch: Branch {
    let name: String
    let targetHash: String
    let commits: [GithubCommit]
}

extension GithubBranch: JSONInitializable {
    init(json: JSON) throws {
        guard let node = json["node"] as? JSON,
            let name = node["name"] as? String,
            let target = node["target"] as? JSON,
            let history = target["history"] as? JSON,
            let edges = history["edges"] as? [JSON]
            else { throw JSONParsingError() }

        guard let first = edges.first,
            let edgeNode = first["node"] as? JSON,
            let oid = edgeNode["oid"] as? String
            else { throw GithubDiscardRefError() }

        // TODO: Test this
        let commits = try edges.flatMap ({ try GithubCommit(json: $0) })

        self.name = name
        self.targetHash = oid
        self.commits = commits
    }
}

extension GithubBranch: UUIDEquatable {
    var uuid: String {
        return targetHash
    }
}
