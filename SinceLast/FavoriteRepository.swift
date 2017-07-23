//
//  FavoriteRepository.swift
//  SinceLast
//
//  Created by James Kuang on 5/31/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class FavoriteRepository: NSObject, NSCoding {
    enum CodableKey {
        static let uuid = "uuid"
        static let name = "name"
        static let ownerUUID = "ownerUUID"
        static let ownerName = "ownerName"
    }

    let uuid: String
    let name: String
    let ownerUUID: String
    let ownerName: String

    fileprivate init(uuid: String, name: String, ownerUUID: String, ownerName: String) {
        self.uuid = uuid
        self.name = name
        self.ownerUUID = ownerUUID
        self.ownerName = ownerName
    }

    init?(coder aDecoder: NSCoder) {
        guard
            let uuid = aDecoder.decodeObject(forKey: CodableKey.uuid) as? String,
            let name = aDecoder.decodeObject(forKey: CodableKey.name) as? String,
            let ownerUUID = aDecoder.decodeObject(forKey: CodableKey.ownerUUID) as? String,
            let ownerName = aDecoder.decodeObject(forKey: CodableKey.ownerName) as? String
            else { return nil }

        self.uuid = uuid
        self.name = name
        self.ownerUUID = ownerUUID
        self.ownerName = ownerName
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: CodableKey.uuid)
        aCoder.encode(name, forKey: CodableKey.name)
        aCoder.encode(ownerUUID, forKey: CodableKey.ownerUUID)
        aCoder.encode(ownerName, forKey: CodableKey.ownerName)
    }
}

extension FavoriteRepository {
    convenience init(_ repository: Repository) {
        self.init(uuid: repository.uuid, name: repository.name, ownerUUID: repository.ownerUUID, ownerName: repository.ownerName)
    }
}
