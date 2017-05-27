//
//  EnvironmentVariablesReader.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class EnvironmentVariablesReader {
    func read() -> [String: String] {
        return ProcessInfo.processInfo.environment
    }
}
