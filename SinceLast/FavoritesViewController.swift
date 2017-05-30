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
        tableView.estimatedRowHeight = 70.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
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

    fileprivate var repositories: [Repository] = [] {
        didSet {
            updateEmptyStateVisibility()
        }
    }

    init(client: GitClient) {
        self.gitClient = client
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Favorites", comment: "Favorites screen navigation bar title")
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
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyView.actionButton.addTarget(self, action: #selector(tappedAddFavorite(_:)), for: .touchUpInside)
        updateEmptyStateVisibility()
        fetchData()
    }

    private func fetchData() {
        let _ = self.retrieveUser().then(execute: { user in
            self.currentUser = user
        })

        self.repositories = []
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
        emptyView.isHidden = !repositories.isEmpty
    }

    private dynamic func tappedSettingsButton(_ sender: UIBarButtonItem) {
        guard let user = self.currentUser else { return }
        let controller = SettingsViewController(currentUser: user)
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }

    private dynamic func tappedAddFavorite(_ sender: UIBarButtonItem) {
        guard let user = self.currentUser else { return }
        let controller = RepositoriesViewController(currentUser: user, client: gitClient)
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }
}

final class EmptyView: UIView {
    fileprivate let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    fileprivate let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(ThemeColor.darkOrange.color, for: .normal)
        button.setTitleColor(ThemeColor.lightOrange.color, for: .highlighted)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5.0
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(stackView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
