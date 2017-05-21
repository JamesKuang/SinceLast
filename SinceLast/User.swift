//
//  User.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct User {
    let name: String
}

extension User: JSONInitializable {
    init(json: JSON) throws {
        guard let userName = json["username"] as? String else { throw JSONParsingError() }
        self.name = userName
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
}
