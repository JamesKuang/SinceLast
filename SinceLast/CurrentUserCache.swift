//
//  CurrentUserCache.swift
//  SinceLast
//
//  Created by James Kuang on 6/6/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

final class CurrentUserCache {
    private let storage = PersistentStorage<CurrentUser>()

    init() {}

    var cachedUser: User? {
        guard let currentUser = storage.load().first else { return nil }
        return User(currentUser)
    }

    func cacheUser(_ user: User) {
        storage.save([CurrentUser(user)])
    }
}
