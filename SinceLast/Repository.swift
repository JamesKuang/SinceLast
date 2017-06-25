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

}

// MARK: - BitbucketRepository

struct BitbucketRepository {
    let uuid: String
    let name: String
    let description: String
    let language: String
    let owner: User
    let avatarURL: String
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
        self.owner = try BitbucketUser(json: owner) // FIXME:
        self.avatarURL = avatarURL
    }
}
