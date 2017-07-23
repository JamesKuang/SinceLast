//
//  User.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol User: JSONInitializable, UUIDEquatable {
    var uuid: String { get }
    var name: String { get }

    init(_ currentUser: CurrentUser)
}

// MARK: - BitbucketUser

struct BitbucketUser: User {
    enum Kind: String {
        case user = "user"
        case team = "team"
    }

    let uuid: String
    let name: String
    let kind: Kind
}

extension BitbucketUser: Equatable {
    static func == (lhs: BitbucketUser, rhs: BitbucketUser) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension BitbucketUser: JSONInitializable {
    init(json: JSON) throws {
        guard
            let uuid = json["uuid"] as? String,
            let userName = json["username"] as? String,
            let kindString = json["type"] as? String,
            let kind = Kind(rawValue: kindString)
            else { throw JSONParsingError() }
        self.uuid = uuid
        self.name = userName
        self.kind = kind
    }
}

extension BitbucketUser {
    init(_ currentUser: CurrentUser) {
        self.uuid = currentUser.uuid
        self.name = currentUser.name
        self.kind = .user
    }
}

// MARK: - GithubUser

struct GithubUser: User {
    let uuid: String
    let name: String
}

extension GithubUser: Equatable {
    static func == (lhs: GithubUser, rhs: GithubUser) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension GithubUser: JSONInitializable {
    init(json: JSON) throws {
        guard
            let id = json["id"] as? String,
            let name = json["login"] as? String
            else { throw JSONParsingError() }
        self.uuid = id
        self.name = name
    }
}

extension GithubUser {
    init(_ currentUser: CurrentUser) {
        self.uuid = currentUser.uuid
        self.name = currentUser.name
    }
}
