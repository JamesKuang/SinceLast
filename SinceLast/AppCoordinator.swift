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

    private(set) lazy var router: AppRouter = AppRouter(rootViewController: self.rootViewController)
    private(set) lazy var shortcutInteractor: ShortcutActionInteractor = ShortcutActionInteractor(coordinator: self)

    var isAuthorized: Bool {
        let tokenStorage = TokenStorage(service: gitClient.service)
        return tokenStorage.hasToken
    }

    init() {
        setupAppearanceProxies()
        shortcutInteractor.setupShortcutsCreation()

        NotificationCenter.default.addObserver(self, selector: #selector(didLogoutGitService(_:)), name: .didLogoutGitService, object: nil)
    }

    private func setupAppearanceProxies() {
        let color = ThemeColor.darkOrange.color
        UIBarButtonItem.appearance().tintColor = color
        UINavigationBar.appearance().tintColor = color
    }

    @discardableResult
    func startLaunchViewController() -> UINavigationController {
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        router.routeToLaunchViewController(client: gitClient, isAuthorized: isAuthorized)
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

        let storage = PersistentStorage<FavoriteRepository>()
        storage.purge()
        
        startLaunchViewController()
    }
}

extension Notification.Name {
    static let didLogoutGitService = Notification.Name("didLogoutGitService")
}
