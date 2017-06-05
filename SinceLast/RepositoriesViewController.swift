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

    fileprivate let loadDistance: CGFloat = 10.0

    fileprivate var nextPage: Int? = nil

    init(owner: User, client: GitClient) {
        self.owner = owner
        self.gitClient = client
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Repositories", comment: "Repositories screen navigation bar title")

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
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    private func fetchData() {
        let _ = retrieveRepositories(for: owner).then(execute: { repositories in
            self.repositories = repositories
        })
    }

    fileprivate func fetchNextPageData() {
        guard let nextPage = self.nextPage else { return }
        let _ = retrieveRepositories(for: owner, page: nextPage).then(execute: { repositories in
            self.repositories += repositories
        })
    }

    fileprivate func retrieveRepositories(for owner: User, page: Int = 1) -> Promise<[Repository]> {
        let request = BitbucketRepositoriesRequest(uuid: owner.uuid, page: page)
        return gitClient.send(request: request).then(execute: { result -> [Repository] in
            if let page = result.page {
                self.nextPage = page + 1
            } else {
                self.nextPage = nil
            }

            return result.objects
        })
    }

    private func reload() {
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    fileprivate func saveRepositoryAsFavorite(_ repository: Repository) {
        let codable = FavoriteRepository(repository)

        let storage: PersistentStorage<FavoriteRepository> = PersistentStorage()
        var favorites = storage.load() ?? []
        favorites.append(codable)

        storage.save(favorites)
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
        guard nextPage != nil, indexPath.row == repositories.count - 1 else { return }
        fetchNextPageData()
    }
}
