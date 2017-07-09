//
//  Repository.swift
//  SinceLast
//
//  Created by James Kuang on 5/21/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol Repository: JSONInitializable, UUIDEquatable {
    var uuid: String { get }
    var name: String { get }
    var description: String { get }

    var ownerUUID: String { get }
    var ownerName: String { get }
}

// MARK: - BitbucketRepository

struct BitbucketRepository: Repository {
    let uuid: String
    let name: String
    let description: String
    let language: String
    let owner: User
    let avatarURL: String

    var ownerUUID: String {
        return owner.uuid
    }

    var ownerName: String {
        return owner.name
    }
}

extension BitbucketRepository: JSONInitializable {
    init(json: JSON) throws {
        guard
            let uuid = json["uuid"] as? String,
            let name = json["name"] as? String,
            let description = json["description"] as? String,
            let language = json["language"] as? String,
            let owner = json["owner"] as? JSON,
            let links = json["links"] as? JSON,
            let avatarLink = links["avatar"] as? JSON,
            let avatarURL = avatarLink["href"] as? String
            else { throw JSONParsingError() }

        self.uuid = uuid
        self.name = name
        self.description = description
        self.language = language
        self.owner = try BitbucketUser(json: owner)
        self.avatarURL = avatarURL
    }
}

// MARK: GithubRepository

struct GithubRepository: Repository {
    let uuid: String
    let name: String
    let description: String
    let owner: GithubUser

    var ownerUUID: String {
        return owner.uuid
    }

    var ownerName: String {
        return owner.name
    }
}

extension GithubRepository: JSONInitializable {
    init(json: JSON) throws {
        guard
            let node = json["node"] as? JSON,
            let uuid = node["id"] as? String,
            let name = node["name"] as? String
//            let owner = node["owner"] as? JSON    // TODO: this may or may not be needed for Github
            else { throw JSONParsingError() }

        self.uuid = uuid
        self.name = name
        self.description = node["description"] as? String ?? ""
        self.owner = GithubUser(uuid: "", name: "")
    }
}
