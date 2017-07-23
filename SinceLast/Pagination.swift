//
//  Pagination.swift
//  SinceLast
//
//  Created by James Kuang on 7/3/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum Pagination {
    case initial
    case integer(Int)
    case cursor(String)
    case none

    var hasNextPage: Bool {
        guard case .none = self else { return true }
        return false
    }

    var integerPage: Int? {
        switch self {
        case .initial: return 1
        case .integer(let page): return page
        case .cursor: return nil
        case .none: return nil
        }
    }

    var cursorPage: String? {
        guard case .cursor(let cursor) = self else { return nil }
        return cursor
    }
}
