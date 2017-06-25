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

    let service: GitService

    init(service: GitService) {
        self.service = service
    }

    var cachedUser: User? {
        guard let currentUser = storage.load().first else { return nil }
        switch service {
        case .bitbucket: return BitbucketUser(currentUser)
        case .github: return GithubUser(currentUser)
        }
    }

    func cacheUser(_ user: User) {
        storage.save([CurrentUser(user)])
    }
}
