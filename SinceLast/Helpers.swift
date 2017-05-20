//
//  Helpers.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

extension Date {
    var dataRepresentationSince1970: Data {
        var interval = timeIntervalSince1970
        return Data(bytes: &interval, count: MemoryLayout<TimeInterval>.size)
    }
}

extension Data {
    var dateRepresentationSince1970: Date {
        let interval: TimeInterval = withUnsafeBytes { $0.pointee }
        return Date(timeIntervalSince1970: interval)
    }
}
