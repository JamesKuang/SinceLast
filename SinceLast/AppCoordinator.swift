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

    var gitClient: GitClient = GitClient(service: .bitbucket)

    var isAuthorized: Bool {
        let tokenStorage = TokenStorage(service: gitClient.service)
        guard let token = tokenStorage.token else { return false }
        return !token.isExpired
    }

    init() {

    }

    func startLaunchViewController() -> UIViewController {
        let controller: UIViewController
        if isAuthorized {
            controller = RepositoriesViewController(client: gitClient)
        } else {
            let credentials = [BitbucketOAuth()]
            controller = GitServicesAuthorizationViewController(credentials: credentials)
        }

        let rootViewController = UINavigationController(rootViewController: controller)
        self.rootViewController = rootViewController
        return rootViewController
    }

    func handleOAuthURL(_ url: URL) -> Bool {
        let validator = OAuthURLValidator(url: url, expectedScheme: "sincelast")
        switch validator.result {
        case .success(let code):
            gitClient.authorize(code: code, success: {
                _ = self.startLaunchViewController()
            })
            return true
        case .failure(let error):
            print(error)
            return false
        }
    }
}
