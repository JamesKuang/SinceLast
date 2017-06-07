//
//  CurrentUser.swift
//  SinceLast
//
//  Created by James Kuang on 6/6/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class CurrentUser: NSObject, NSCoding {
    enum CodableKey {
        static let uuid = "uuid"
        static let name = "name"
    }

    let uuid: String
    let name: String

    fileprivate init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }

    init?(coder aDecoder: NSCoder) {
        guard
            let uuid = aDecoder.decodeObject(forKey: CodableKey.uuid) as? String,
            let name = aDecoder.decodeObject(forKey: CodableKey.name) as? String
            else { return nil }

        self.uuid = uuid
        self.name = name
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: CodableKey.uuid)
        aCoder.encode(name, forKey: CodableKey.name)
    }
}

extension CurrentUser {
    convenience init(_ user: User) {
        self.init(uuid: user.uuid, name: user.name)
    }
}

extension User {
    init(_ currentUser: CurrentUser) {
        self.uuid = currentUser.uuid
        self.name = currentUser.name
        self.kind = .user
    }
}
