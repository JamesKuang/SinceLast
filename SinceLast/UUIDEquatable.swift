//
//  UUIDEquatable.swift
//  SinceLast
//
//  Created by James Kuang on 6/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol UUIDEquatable {
    var uuid: String { get }
}

struct UUIDEquality: Equatable {
    let equatable: UUIDEquatable

    init(_ equatable: UUIDEquatable) {
        self.equatable = equatable
    }

    static func == (lhs: UUIDEquality, rhs: UUIDEquality) -> Bool {
        return lhs.equatable.uuid == rhs.equatable.uuid
    }
}
