//
//  BitbucketResults.swift
//  SinceLast
//
//  Created by James Kuang on 6/4/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct BitbucketArrayResult<T: JSONInitializable>: JSONInitializable {
    let objects: [T]

    init(json: JSON) throws {
        guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
        self.objects = try values.flatMap { try T(json: $0) }
    }
}
