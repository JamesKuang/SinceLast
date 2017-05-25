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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.itemSize = CGSize(width: self.view.bounds.width, height: 70.0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()

    fileprivate var repositores: [Repository] = []

    init(client: GitClient) {
        self.gitClient = client
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Repositories", comment: "Repositories screen navigation bar title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(tappedSettingsButton(_:)))

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(cell: RepositoryCell.self)
        collectionView.dataSource = self

        fetchData()
    }

    private func fetchData() {
        let _ = retrieveUser()
            .then { user in
                self.retrieveRepositories(for: user)
            }.then { repositories in
                self.reload(with: repositories)
            }.catch { error in
                print(error)
        }
    }

    private func retrieveUser() -> Promise<User> {
        let request = BitbucketUserRequest()
        return gitClient.send(request: request)
    }

    private func retrieveRepositories(for user: User) -> Promise<[Repository]> {
        let request = BitbucketRepositoriesRequest(userName: user.name)
        return gitClient.send(request: request).then(execute: { result -> [Repository] in
            return result.repositories
        })
    }

    private func reload(with repositories: [Repository]) {
        print(repositories)
        self.repositores = repositories
        collectionView.reloadData()
    }

    private dynamic func tappedSettingsButton(_ sender: UIBarButtonItem) {
        let controller = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }
}

extension RepositoriesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return repositores.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(of: RepositoryCell.self, for: indexPath)
        let repository = repositores[indexPath.item]
        cell.configure(with: repository)
        return cell
    }
}
