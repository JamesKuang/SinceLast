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

struct BitbucketPaginatedResult<T: JSONInitializable>: JSONInitializable {
    let objects: [T]

    let page: Int?
    let next: URL?

    init(json: JSON) throws {
        guard let values = json["values"] as? [JSON] else { throw JSONParsingError() }
        self.objects = try values.flatMap { try T(json: $0) }

        if let nextString = json["next"] as? String, let next = URL(string: nextString) {
            self.next = next
            self.page = json["page"] as? Int
        } else {
            self.next = nil
            self.page = nil
        }
    }
}
