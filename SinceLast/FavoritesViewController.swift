//
//  FavoritesViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/29/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

final class FavoritesViewController: UIViewController, GitClientRequiring {
    let gitClient: GitClient

    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.tableFooterView = UIView(frame: .zero)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ThemeColor.darkOrange.color
        tableView.refreshControl = refreshControl
        return tableView
    }()

    private let emptyView: EmptyView = {
        let view = EmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.messageLabel.text = NSLocalizedString("No repositories yet, add one to get started.", comment: "Favorites screen empty state message")
        view.actionButton.setTitle(NSLocalizedString("Add Repository", comment: "Favorites screen empty state action button to add a repository"), for: .normal)
        return view
    }()

    fileprivate var currentUser: User? {
        didSet {
            updateCurrentUserUIVisibility(currentUser != nil)
        }
    }

    fileprivate var favorites: [FavoriteRepository] = [] {
        didSet {
            updateEmptyStateVisibility()
        }
    }

    private lazy var storage: PersistentStorage<FavoriteRepository> = PersistentStorage()
    private let currentUserCache: CurrentUserCache

    init(client: GitClient) {
        self.gitClient = client
        self.currentUserCache = CurrentUserCache()
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Repositories", comment: "Favorites screen navigation bar title")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(tappedSettingsButton(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedAddFavorite(_:)))

        updateCurrentUserUIVisibility(false)

        view.addSubview(tableView)
        view.addSubview(emptyView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: FavoriteCell.self)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)
        emptyView.actionButton.addTarget(self, action: #selector(tappedAddFavorite(_:)), for: .touchUpInside)
        registerForPreviewing(with: self, sourceView: tableView)

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        loadFavorites()

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    private func fetchData() {
        if let cachedUser = currentUserCache.cachedUser {
            self.currentUser = cachedUser
            return
        }

        let _ = self.retrieveUser().then(execute: { user -> Void in
            self.currentUserCache.cacheUser(user)
            self.currentUser = user
            self.tableView.refreshControl?.endRefreshing()
        })
    }

    private func loadFavorites() {
        favorites = storage.load() ?? []
        tableView.reloadData()
    }

    fileprivate func deleteFavorite(at index: Int) {
        favorites.remove(at: index)
        storage.save(favorites)
    }

    private func retrieveUser() -> Promise<User> {
        let request = BitbucketUserRequest()
        return gitClient.send(request: request)
    }

    private func updateCurrentUserUIVisibility(_ hasUser: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = hasUser
        navigationItem.rightBarButtonItem?.isEnabled = hasUser
        emptyView.actionButton.isEnabled = hasUser
    }

    private func updateEmptyStateVisibility() {
        emptyView.isHidden = !favorites.isEmpty
    }

    fileprivate func nextViewController(for indexPath: IndexPath) -> UIViewController? {
        guard let user = self.currentUser else { return nil }
        let favorite = favorites[indexPath.row]
        return CommitsViewController(client: gitClient, currentUser: user, repository: favorite)
    }

    private dynamic func tappedSettingsButton(_ sender: UIBarButtonItem) {
        guard let user = self.currentUser else { return }
        let controller = SettingsViewController(currentUser: user)
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }

    private dynamic func tappedAddFavorite(_ sender: UIBarButtonItem) {
        guard let user = self.currentUser else { return }
        let controller = RepositoryOwnersViewController(currentUser: user, client: gitClient)
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }

    private dynamic func refreshControlValueChanged(_ sender: UIRefreshControl) {
        fetchData()
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: FavoriteCell.self, for: indexPath)
        let favorite = favorites[indexPath.row]
        cell.configure(with: favorite)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = nextViewController(for: indexPath) else { return }
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deleteFavorite(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension FavoritesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        if let cell = tableView.cellForRow(at: indexPath) {
            previewingContext.sourceRect = cell.frame
        }
        return nextViewController(for: indexPath)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
