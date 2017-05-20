//
//  RepositoriesViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

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
            let request = BitbucketRepositoriesRequest()
            gitClient.send(request: request, completion: { result in
                switch result {
                case .success(let json):
                    print(json)
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}
