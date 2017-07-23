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

        self.name = name
        self.targetHash = oid
    }
}

extension GithubBranch: UUIDEquatable {
    var uuid: String {
        return targetHash
    }
}
