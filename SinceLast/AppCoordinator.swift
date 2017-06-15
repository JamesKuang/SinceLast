//
//  AppCoordinator.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

enum AuthState {
    case authorized(gitClient: GitClient)
    case notAuthorized
}

final class AppCoordinator {
    private lazy var rootViewController = UINavigationController()

    private(set) lazy var router: AppRouter = AppRouter(rootViewController: self.rootViewController)
    private(set) lazy var shortcutInteractor: ShortcutActionInteractor = ShortcutActionInteractor(coordinator: self)

    private(set) var authState: AuthState = .notAuthorized

    init() {
        setupAppearanceProxies()
        updateAuthState()
        shortcutInteractor.setupShortcutsCreation()

        NotificationCenter.default.addObserver(self, selector: #selector(didLogoutGitService(_:)), name: .didLogoutGitService, object: nil)
    }

    private func setupAppearanceProxies() {
        let color = ThemeColor.darkOrange.color
        UIBarButtonItem.appearance().tintColor = color
        UINavigationBar.appearance().tintColor = color
    }

    private func updateAuthState() {
        let supportedGitServices: [GitService] = [
            .github,
            .bitbucket,
            ].filter { $0.isSupported }

        let indexWithToken = supportedGitServices
            .lazy
            .map { TokenStorage(service: $0) }
            .index { $0.hasToken }

        if let index = indexWithToken {
            let client = GitClient(service: supportedGitServices[index])
            authState = .authorized(gitClient: client)
        } else {
            authState = .notAuthorized
        }
    }

    @discardableResult
    func startLaunchViewController() -> UINavigationController {
        if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.dismiss(animated: false)
        }

        router.routeToLaunchViewController(authState: authState)
        return rootViewController
    }

    func handleOAuthURL(_ url: URL) -> Bool {
        let validator = OAuthCallbackValidator(url: url, expectedScheme: "sincelast")
        switch validator.result {
        case .success(let result):
            let oAuthClient = OAuthClient(service: result.service)
            let _ = oAuthClient.authorize(code: result.code).then(execute: { _ -> Void in
                self.updateAuthState()
                self.startLaunchViewController()
            })
            return true
        case .failure(let error):
            print(error)
            return false
        }
    }

    private dynamic func didLogoutGitService(_ notification: Notification) {
        guard case .authorized(let gitClient) = authState else { return }

        let tokenStorage = TokenStorage(service: gitClient.service)
        tokenStorage.clearToken()

        let repositoriesStorage = PersistentStorage<FavoriteRepository>()
        repositoriesStorage.purge()

        let userStorage = PersistentStorage<CurrentUser>()
        userStorage.purge()

        authState = .notAuthorized
        
        startLaunchViewController()
    }
}

extension Notification.Name {
    static let didLogoutGitService = Notification.Name("didLogoutGitService")
}
