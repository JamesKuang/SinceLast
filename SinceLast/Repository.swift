//
//  Repository.swift
//  SinceLast
//
//  Created by James Kuang on 5/21/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Repository {
    let uuid: String
    let name: String
    let description: String
    let language: String
}

extension Repository: JSONInitializable {
    init(json: JSON) throws {
        guard
            let uuid = json["uuid"] as? String,
            let name = json["name"] as? String,
            let description = json["description"] as? String,
            let language = json["language"] as? String
            else { throw JSONParsingError() }
        self.uuid = uuid
        self.name = name
        self.description = description
        self.language = language
    }
}

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
