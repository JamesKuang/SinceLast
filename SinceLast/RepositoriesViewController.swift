//
//  RepositoriesViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

final class RepositoriesViewController: UIViewController, GitClientRequiring {
    let gitClient: GitClient

    init(client: GitClient) {
        self.gitClient = client
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Repositories", comment: "Repositories screen navigation bar title")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParentViewController {
            fetchData()
        }
    }

    private func fetchData() {
        let _ = retrieveUser()
            .then { user in
                self.retrieveRepositories(for: user)
            }.then { repository in
                print(repository)
            }.catch { error in
                print(error)
        }
    }

    private func retrieveUser() -> Promise<User> {
        let request = BitbucketUserRequest()
        return gitClient.send(request: request)
    }

    private func retrieveRepositories(for user: User) -> Promise<Repository> {
        let request = BitbucketRepositoriesRequest(userName: user.name)
        return gitClient.send(request: request)
    }
}
