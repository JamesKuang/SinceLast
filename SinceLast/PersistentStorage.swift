//
//  PersistentStorage.swift
//  SinceLast
//
//  Created by James Kuang on 5/31/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let persistentStorageContentDidChange = Notification.Name("persistentStorageContentDidChange")
}

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
        if result {
            postContentDidChangeNotification()
        } else {
            print("Failed archiving to file '\(fileName)'")
        }
        return result
    }

    func load() -> [T] {
        guard let objects = NSKeyedUnarchiver.unarchiveObject(withFile: storageURL.path) as? [T] else { return [] }
        return objects
    }

    func purge() {
        do {
            try FileManager.default.removeItem(at: storageURL)
            postContentDidChangeNotification()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    private func postContentDidChangeNotification() {
        NotificationCenter.default.post(name: .persistentStorageContentDidChange, object: nil)
    }
}

extension PersistentStorage {
    convenience init() {
        self.init(fileName: String(describing: T.self))
    }
}
