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

struct BitbucketBranch {
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

struct GithubBranch {
    let name: String
    let targetHash: String
}

extension GithubBranch: JSONInitializable {
    init(json: JSON) throws {
        guard let name = json["name"] as? String,
            let target = json["target"] as? JSON,
            let history = target["history"] as? JSON,
            let edges = history["edges"] as? [JSON]
            else { throw JSONParsingError() }

        guard let first = edges.first,
            let node = first["node"] as? JSON,
            let old = node["old"] as? String
            else { throw NilError() }

        self.name = name
        self.targetHash = old
    }
}

extension GithubBranch: UUIDEquatable {
    var uuid: String {
        return targetHash
    }
}
