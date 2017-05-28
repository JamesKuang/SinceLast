//
//  RepositoriesViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

struct RepositorySection {
    let repositoryOwner: RepositoryOwner
    let repositories: [Repository]
}

final class RepositoriesViewController: UIViewController, GitClientRequiring {
    let gitClient: GitClient

    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        return tableView
    }()

    fileprivate var currentUser: User?
    fileprivate var repositorySections: [RepositorySection] = []

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

        registerForPreviewing(with: self, sourceView: tableView)

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
        let retrieveUser = self.retrieveUser()
        let retrieveTeams = self.retrieveTeams()

        when(fulfilled: retrieveUser, retrieveTeams).then { (user, teams) -> Promise<[RepositorySection]> in
            let usersRepositories = self.retrieveRepositories(for: user)
            let teamsRepositories = self.retrieveTeamsRepositories(for: teams)
            let teamOwnedRepositores = self.retrieveTeamOwnedRepositories(for: teams)
            return when(fulfilled: [usersRepositories] + teamsRepositories + teamOwnedRepositores)
            }.then { repositorySections in
                self.reload(with: repositorySections)
            }.catch { error in
                print(error)
        }
    }

    private func retrieveUser() -> Promise<User> {
        let request = BitbucketUserRequest()
        return gitClient.send(request: request).then(execute: { user -> Promise<User> in
            self.currentUser = user
            return Promise(value: user)
        })
    }

    private func retrieveTeams() -> Promise<[Team]> {
        let request = BitbucketTeamsRequest()
        return gitClient.send(request: request).then(execute: { result -> [Team] in
            return result.teams
        })
    }

    private func retrieveRepositories(for user: User) -> Promise<RepositorySection> {
        let request = BitbucketRepositoriesRequest(userName: user.uuid)
        return gitClient.send(request: request).then(execute: { result -> RepositorySection in
            return RepositorySection(repositoryOwner: .user(user), repositories: result.repositories)
        })
    }

    private func retrieveTeamsRepositories(for teams: [Team]) -> [Promise<RepositorySection>] {
        return teams.map { team -> Promise<RepositorySection> in
            let request = BitbucketRepositoriesRequest(userName: team.uuid)
            return gitClient.send(request: request).then(execute: { result -> RepositorySection in
                return RepositorySection(repositoryOwner: .team(team), repositories: result.repositories)
            })
        }
    }

    private func retrieveTeamOwnedRepositories(for teams: [Team]) -> [Promise<RepositorySection>] {
        return teams.map { team -> Promise<RepositorySection> in
            let request = BitbucketTeamRepositoriesRequest(userName: team.uuid)
            return gitClient.send(request: request).then(execute: { result -> RepositorySection in
                return RepositorySection(repositoryOwner: .team(team), repositories: result.repositories)
            })
        }
    }

    private func reload(with repositorySections: [RepositorySection]) {
        self.repositorySections = repositorySections
        tableView.reloadData()
    }

    private dynamic func tappedSettingsButton(_ sender: UIBarButtonItem) {
        guard let user = self.currentUser else { return }
        let controller = SettingsViewController(currentUser: user)
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }

    fileprivate func commitsController(for indexPath: IndexPath) -> CommitsViewController {
        let repositoryGroup = repositorySections[indexPath.section]
        let repository = repositoryGroup.repositories[indexPath.row]
        return CommitsViewController(client: gitClient, repositoryOwner: repositoryGroup.repositoryOwner, repository: repository)
    }
}

extension RepositoriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return repositorySections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let repositorySection = repositorySections[section]
        return repositorySection.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: RepositoryCell.self, for: indexPath)
        let repositorySection = repositorySections[indexPath.section]
        let repository = repositorySection.repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let repositorySection = repositorySections[section]
        return repositorySection.repositoryOwner.name
    }
}

extension RepositoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = commitsController(for: indexPath)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension RepositoriesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let controller = commitsController(for: indexPath)
        return controller
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
