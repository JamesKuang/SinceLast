//
//  AppCoordinator.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class AppCoordinator {
    private(set) var rootViewController: UIViewController?

    var isAuthorized: Bool {
        return false // TODO:
    }

    init() {

    }

    func startLaunchViewController() -> UIViewController {
        let controller: UIViewController
        if isAuthorized {
            controller = RepositoriesViewController()
        } else {
            let services = [BitbucketService()]
            controller = GitServicesAuthorizationViewController(services: services)
        }

        let rootViewController = UINavigationController(rootViewController: controller)
        self.rootViewController = rootViewController
        return rootViewController
    }

    func handleOAuthURL(_ url: URL) -> Bool {
        let validator = OAuthURLValidator(url: url, expectedScheme: "sincelast")
        guard validator.isValid else { return false }

        return true
    }
}
