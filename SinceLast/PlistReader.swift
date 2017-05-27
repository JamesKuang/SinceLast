//
//  PlistReader.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class PlistReader {
    let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func read() -> NSDictionary {
        guard let plistPath = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let contents = NSDictionary(contentsOfFile: plistPath)
            else { fatalError("No Plist found") }
        return contents
    }
}
