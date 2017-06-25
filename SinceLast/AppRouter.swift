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

    func routeToLaunchViewController(authState: AuthState) {
        let controller: UIViewController
        switch authState {
        case .authorized(let gitClient):
            controller = FavoritesViewController(client: gitClient)
        case .notAuthorized:
            controller = GitServicesAuthorizationViewController()
        }
        rootViewController.setViewControllers([controller], animated: false)
    }

    func routeToCommits(for repository: FavoriteRepository) {
        guard let favoritesViewController = rootViewController.topViewController as? FavoritesViewController else { return }

        let gitClient = favoritesViewController.gitClient
        let currentUserCache = CurrentUserCache(service: gitClient.service)
        guard let currentUser = currentUserCache.cachedUser else { return }

        let controller = CommitsViewController(client: gitClient, currentUser: currentUser, repository: repository)
        rootViewController.pushViewController(controller, animated: false)
    }
}
