//
//  AppRouter.swift
//  SinceLast
//
//  Created by James Kuang on 6/6/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class AppRouter {
    private let rootViewController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }

    func routeToCommits(in repository: FavoriteRepository) {
        guard let favoritesViewController = rootViewController.topViewController as? FavoritesViewController else { return }

        let currentUserCache = CurrentUserCache()
        guard let currentUser = currentUserCache.cachedUser else { return }

        let gitClient = favoritesViewController.gitClient
        let controller = CommitsViewController(client: gitClient, currentUser: currentUser, repository: repository)
        rootViewController.pushViewController(controller, animated: false)
    }
}
