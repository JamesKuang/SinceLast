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

    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.tableFooterView = UIView(frame: .zero)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ThemeColor.darkOrange.color
        tableView.refreshControl = refreshControl
        return tableView
    }()

    fileprivate let owner: User
    fileprivate var repositories: [Repository] = [] {
        didSet {
            reload()
        }
    }

    fileprivate var nextPage: Pagination = .initial

    init(owner: User, client: GitClient, dismissable: Bool) {
        self.owner = owner
        self.gitClient = client
        super.init(nibName: nil, bundle: nil)

        title = owner.name

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

        if dismissable {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Dismiss screen navigation bar button"), style: .plain, target: self, action: #selector(tappedCloseButton(_:)))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: RepositoryCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    fileprivate func fetchData() {
        guard nextPage.hasNextPage else { return }
        fetchNextPageData(page: nextPage)
            .then(execute: { objects in
                self.repositories.append(contentsOf: objects)
            })
            .always {
                self.tableView.refreshControl?.endRefreshing()
        }
    }

    private func fetchNextPageData(page: Pagination) -> Promise<[Repository]> {
        switch gitClient.service {
        case .github:
            return retrieveRepositories(for: owner, page: page).then(execute: { (result: GithubArrayResult<GithubRepository, GithubRepositoriesRequest>) -> [Repository] in
                if result.hasNextPage {
                    self.nextPage = .cursor(result.endCursor)
                } else {
                    self.nextPage = .none
                }

                return result.objects
            })
        case .bitbucket:
            return retrieveRepositories(for: owner, page: page).then(execute: { (result: BitbucketPaginatedResult<BitbucketRepository>) -> Promise<[Repository]> in
                if let page = result.page {
                    self.nextPage = .integer(page + 1)
                } else {
                    self.nextPage = .none
                }

                return Promise(value: result.objects)
            })
        }
    }

    fileprivate func retrieveRepositories<T: JSONInitializable>(for owner: User, page: Pagination) -> Promise<T> {
        return gitClient.send(request: gitClient.service.repositoriesRequest(page: page, ownerUUID: owner.uuid))
    }

    private func reload() {
        tableView.reloadData()
    }

    fileprivate func saveRepositoryAsFavorite(_ repository: Repository) {
        let codable = FavoriteRepository(repository)

        let storage: PersistentStorage<FavoriteRepository> = PersistentStorage()
        var favorites = storage.load() 
        favorites.append(codable)

        storage.save(favorites)
    }

    private dynamic func tappedCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    private dynamic func refreshControlValueChanged(_ sender: UIRefreshControl) {
        fetchData()
    }

    fileprivate func dismiss() {
        dismiss(animated: true)
    }
}

extension RepositoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: RepositoryCell.self, for: indexPath)
        let repository = repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }
}

extension RepositoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        saveRepositoryAsFavorite(repository)

        dismiss()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard nextPage.hasNextPage, indexPath.row == repositories.count - 1 else { return }
        _ = fetchData()
    }
}
