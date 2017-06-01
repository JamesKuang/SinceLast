//
//  CodableRepository.swift
//  SinceLast
//
//  Created by James Kuang on 5/31/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class CodableRepository: NSObject, NSCoding {
    enum CodableKey {
        static let uuid = "uuid"
        static let name = "name"
        static let ownerName = "ownerName"
    }

    let uuid: String
    let name: String
    let ownerName: String

    fileprivate init(uuid: String, name: String, ownerName: String) {
        self.uuid = uuid
        self.name = name
        self.ownerName = ownerName
    }

    init?(coder aDecoder: NSCoder) {
        guard
            let uuid = aDecoder.decodeObject(forKey: CodableKey.uuid) as? String,
            let name = aDecoder.decodeObject(forKey: CodableKey.name) as? String,
            let ownerName = aDecoder.decodeObject(forKey: CodableKey.ownerName) as? String
            else { return nil }

        self.uuid = uuid
        self.name = name
        self.ownerName = ownerName
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: CodableKey.uuid)
        aCoder.encode(name, forKey: CodableKey.name)
        aCoder.encode(ownerName, forKey: CodableKey.ownerName)
    }
}

extension CodableRepository: UncodableVariantInitializable {
    convenience init(_ object: Repository) {
        self.init(uuid: object.uuid, name: object.name, ownerName: object.owner.name)
    }
}

protocol UncodableVariantInitializable: NSCoding {
    associatedtype T
    init(_ object: T)
}
