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
    let email: String
    let date: String
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name &&
            lhs.email == rhs.email &&
            lhs.date == rhs.date
    }
}
