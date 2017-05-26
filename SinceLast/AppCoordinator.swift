//
//  AppCoordinator.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

final class AppCoordinator {
    private lazy var rootViewController = UINavigationController()

    let gitClient: GitClient = GitClient(service: .bitbucket)

    var isAuthorized: Bool {
        let tokenStorage = TokenStorage(service: gitClient.service)
        guard let token = tokenStorage.token else { return false }
        return !token.isExpired
    }

    init() {
        setAppearanceProxies()
        NotificationCenter.default.addObserver(self, selector: #selector(didLogoutGitService(_:)), name: .didLogoutGitService, object: nil)
    }

    private func setAppearanceProxies() {
        UIBarButtonItem.appearance().tintColor = ThemeColor.darkOrange.color
    }

    @discardableResult
    func startLaunchViewController() -> UIViewController {
        let controller: UIViewController
        if isAuthorized {
            controller = RepositoriesViewController(client: gitClient)
        } else {
            let credentials: [OAuthCredentials] = [
                GithubOAuth(),
                BitbucketOAuth(),
                ]
            controller = GitServicesAuthorizationViewController(credentials: credentials)
        }

        rootViewController.setViewControllers([controller], animated: false)
        return rootViewController
    }

    func handleOAuthURL(_ url: URL) -> Bool {
        let validator = OAuthURLValidator(url: url, expectedScheme: "sincelast")
        switch validator.result {
        case .success(let code):
            let _ = gitClient.authorize(code: code).then(execute: { _ in
                self.startLaunchViewController()
            })
            return true
        case .failure(let error):
            print(error)
            return false
        }
    }

    private dynamic func didLogoutGitService(_ notification: Notification) {
        let tokenStorage = TokenStorage(service: gitClient.service)
        tokenStorage.clearToken()
        startLaunchViewController()
    }
}

extension Notification.Name {
    static let didLogoutGitService = Notification.Name("didLogoutGitService")
}
