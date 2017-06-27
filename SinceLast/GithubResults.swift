//
//  GithubResults.swift
//  SinceLast
//
//  Created by James Kuang on 6/26/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubArrayResult<T: JSONInitializable, U: GithubGraphTraversing>: JSONInitializable {
    let objects: [T]

    init(json: JSON) throws {
        let connections = U.connections
        var dictionary = json

        for connection in connections {
            let value = dictionary[connection]
            if let next = value as? JSON {
                dictionary = next
            } else if let values = value as? [JSON] {
                self.objects = try values.flatMap { try T(json: $0) }
                return
            } else {
                throw JSONParsingError()
            }
        }
        throw JSONParsingError()
    }
}
