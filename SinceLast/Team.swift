//
//  Team.swift
//  SinceLast
//
//  Created by James Kuang on 5/27/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Team {
    let uuid: String
    let name: String
}

extension Team: JSONInitializable {
    init(json: JSON) throws {
        guard
            let uuid = json["uuid"] as? String,
            let userName = json["username"] as? String
            else { throw JSONParsingError() }
        self.uuid = uuid
        self.name = userName
    }
}

extension Team: Equatable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
