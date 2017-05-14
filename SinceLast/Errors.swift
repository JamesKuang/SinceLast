//
//  Errors.swift
//  SinceLast
//
//  Created by James Kuang on 5/10/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct NilError: Error, CustomStringConvertible {
    let file: String
    let line: Int

    init(file: String = #file, line: Int = #line) {
        self.file = file
        self.line = line
    }

    var description: String {
        return "Nil returned at \((file as NSString).lastPathComponent):\(line)"
    }
}

struct ValidationError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
