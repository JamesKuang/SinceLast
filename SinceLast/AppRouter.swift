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

    func routeToLaunchViewController(client: GitClient, isAuthorized: Bool) {
        let controller: UIViewController
        if isAuthorized {
            controller = FavoritesViewController(client: client)
        } else {
            let credentials: [OAuthCredentials] = [
                GithubOAuth(),
                BitbucketOAuth(),
                ]
            controller = GitServicesAuthorizationViewController(credentials: credentials)
        }
        rootViewController.setViewControllers([controller], animated: false)
    }

    func routeToCommits(for repository: FavoriteRepository) {
        guard let favoritesViewController = rootViewController.topViewController as? FavoritesViewController else { return }

        let currentUserCache = CurrentUserCache()
        guard let currentUser = currentUserCache.cachedUser else { return }

        let gitClient = favoritesViewController.gitClient
        let controller = CommitsViewController(client: gitClient, currentUser: currentUser, repository: repository)
        rootViewController.pushViewController(controller, animated: false)
    }
}
