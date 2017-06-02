//
//  User.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct User {
    enum Kind: String {
        case user = "user"
        case team = "team"
    }

    let uuid: String
    let name: String
    let kind: Kind
}

extension User: JSONInitializable {
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

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
