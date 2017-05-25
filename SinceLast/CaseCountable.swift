//
//  CaseCountable.swift
//  SinceLast
//
//  Created by James Kuang on 5/24/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol CaseCountable { }

extension CaseCountable where Self: RawRepresentable, Self.RawValue == Int {
    static var count: Int {
        var count = 0
        while Self(rawValue: count) != nil { count += 1 }
        return count
    }

    static var allValues: [Self] {
        return (0..<count).flatMap({ Self(rawValue: $0) })
    }
}
