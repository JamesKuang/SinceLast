//
//  User.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct User {
    let uuid: String
    let name: String
}

extension User: JSONInitializable {
    init(json: JSON) throws {
        guard
            let uuid = json["uuid"] as? String,
            let userName = json["username"] as? String
            else { throw JSONParsingError() }
        self.uuid = uuid
        self.name = userName
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
