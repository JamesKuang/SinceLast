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

    var currentGitService: GitService = .bitbucket

    var isAuthorized: Bool {
        let tokenStorage = TokenStorage(service: currentGitService)
        guard let token = tokenStorage.token else { return false }
        return !token.isExpired
    }

    init() {

    }

    func startLaunchViewController() -> UIViewController {
        let controller: UIViewController
        if isAuthorized {
            controller = RepositoriesViewController()
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
            authorize(code: code, service: currentGitService)
            return true
        case .failure(let error):
            print(error)
            return false
        }
    }

    private func authorize(code: String, service: GitService) {
        let request = OAuthAccessTokenRequest(code: code)
        currentGitService.send(request: request, completion: { result in
            switch result {
            case .success(let json):
                guard let token = OAuthAccessToken(json: json) else { return }
                let tokenStorage = TokenStorage(service: service)
                tokenStorage.store(token: token)
            case .failure(let error):
                print(error)
            }
        })
    }
}
