//
//  Branch.swift
//  SinceLast
//
//  Created by James Kuang on 6/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Branch {
    let name: String
    let targetHash: String
}

extension Branch: JSONInitializable {
    init(json: JSON) throws {
        guard let name = json["name"] as? String,
            let target = json["target"] as? JSON,
            let targetHash = target["hash"] as? String
            else { throw JSONParsingError() }

        self.name = name
        self.targetHash = targetHash
    }
}
