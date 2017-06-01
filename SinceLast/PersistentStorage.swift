//
//  PersistentStorage.swift
//  SinceLast
//
//  Created by James Kuang on 5/31/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum StorageDirectory {
    static let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

final class PersistentStorage<T: NSCoding> {
    let fileName: String
    let storageURL: URL

    init(fileName: String, directoryURL: URL = StorageDirectory.documents) {
        self.fileName = fileName
        self.storageURL = directoryURL.appendingPathComponent(fileName)
    }

    @discardableResult
    func save(_ objects: [T]) -> Bool {
        let result = NSKeyedArchiver.archiveRootObject(objects, toFile: storageURL.path)
        if !result {
            print("Failed archiving to file '\(fileName)'")
        }
        return result
    }

    func load() -> [T]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: storageURL.path) as? [T]
    }
}

extension PersistentStorage {
    convenience init() {
        self.init(fileName: String(describing: T.self))
    }
}
