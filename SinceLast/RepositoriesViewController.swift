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

    private lazy var tableView: UITableView = {
        let layout = UICollectionViewFlowLayout()
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        return tableView
    }()

    fileprivate var user: User? // FIXME: Retrieve this before coming to this screen
    fileprivate var repositores: [Repository] = []

    init(client: GitClient) {
        self.gitClient = client
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Repositories", comment: "Repositories screen navigation bar title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(tappedSettingsButton(_:)))

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: RepositoryCell.self)
        tableView.dataSource = self
        tableView.delegate = self

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    private func fetchData() {
        let _ = retrieveUser()
            .then { user in
                self.user = user
                return self.retrieveRepositories(for: user)
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
        self.repositores = repositories
        tableView.reloadData()
    }

    private dynamic func tappedSettingsButton(_ sender: UIBarButtonItem) {
        let controller = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }
}

extension RepositoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: RepositoryCell.self, for: indexPath)
        let repository = repositores[indexPath.item]
        cell.configure(with: repository)
        return cell
    }
}

extension RepositoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = self.user else { fatalError("User should've been retrieved") }
        let repository = repositores[indexPath.item]
        let controller = CommitsViewController(client: gitClient, user: user, repository: repository)
        navigationController?.pushViewController(controller, animated: true)
    }
}
