//
//  RepositoryOwnersViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/29/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

final class RepositoryOwnersViewController: UIViewController, GitClientRequiring {
    enum Section: Int, CaseCountable {
        case userOwner
        case teamOwners

        init(_ section: Int) {
            switch section {
            case 0: self = .userOwner
            case 1: self = .teamOwners
            default: fatalError("Unsupported section")
            }
        }
    }

    let gitClient: GitClient

    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.tableFooterView = UIView(frame: .zero)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ThemeColor.darkOrange.color
        tableView.refreshControl = refreshControl
        return tableView
    }()

    fileprivate let userOwner: [User]
    fileprivate var teamOwners: [User] = [] {
        didSet {
            reload()
        }
    }

    init(currentUser: User, client: GitClient) {
        self.gitClient = client
        self.userOwner = [currentUser]
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Add Repository", comment: "Repository owners screen navigation bar title")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Close settings navigation bar button"), style: .plain, target: self, action: #selector(tappedCloseButton(_:)))

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

        tableView.register(cell: RepositoryOwnerCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)

        registerForPreviewing(with: self, sourceView: tableView)

        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    private func fetchData() {
        let _ = retrieveTeams().then(execute: { teams in
            self.teamOwners = teams
        })
    }

    private func retrieveTeams() -> Promise<[User]> {
        let request = BitbucketTeamsRequest()
        return gitClient.send(request: request).then(execute: { result -> [User] in
            return result.teams
        })
    }

    private func reload() {
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    fileprivate func nextViewController(for indexPath: IndexPath) -> UIViewController {
        let repositoryOwner: User
        switch Section(indexPath.section) {
        case .userOwner: repositoryOwner = userOwner[indexPath.row]
        case .teamOwners: repositoryOwner = teamOwners[indexPath.row]
        }
        return RepositoriesViewController(owner: repositoryOwner, client: gitClient)
    }

    private dynamic func tappedCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    private dynamic func refreshControlValueChanged(_ sender: UIRefreshControl) {
        fetchData()
    }
}

extension RepositoryOwnersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
        case .userOwner: return userOwner.count
        case .teamOwners: return teamOwners.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: RepositoryOwnerCell.self, for: indexPath)

        let repositoryOwner: User
        switch Section(indexPath.section) {
        case .userOwner: repositoryOwner = userOwner[indexPath.row]
        case .teamOwners: repositoryOwner = teamOwners[indexPath.row]
        }

        cell.configure(with: repositoryOwner)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(section) {
        case .userOwner: return nil
        case .teamOwners: return NSLocalizedString("Teams", comment: "Teams repository owner header label")
        }
    }
}

extension RepositoryOwnersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = nextViewController(for: indexPath)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension RepositoryOwnersViewController: UIViewControllerPreviewingDelegate {
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
