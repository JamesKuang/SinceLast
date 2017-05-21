//
//  Repository.swift
//  SinceLast
//
//  Created by James Kuang on 5/21/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Repository {
    let name: String
}

extension Repository: JSONInitializable {
    init?(json: JSON) {
        guard let name = json["name"] as? String else { return nil }
        self.name = name
    }
}

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.name == rhs.name
    }
}
