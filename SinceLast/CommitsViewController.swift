//
//  CommitsViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import PromiseKit

final class CommitsViewController: UIViewController, GitClientRequiring {
    let gitClient: GitClient

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        return tableView
    }()

    fileprivate let user: User
    fileprivate let repository: Repository
    fileprivate var commits: [Commit] = []

    init(client: GitClient, user: User, repository: Repository) {
        self.gitClient = client
        self.user = user
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Commits", comment: "Commits screen navigation bar title")

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

        tableView.register(cell: CommitCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchData()
    }

    private func fetchData() {
        let _ = retrieveCommits()
            .then { commits in
                self.reload(with: commits)
            }.catch { error in
                print(error)
        }
    }

    private func retrieveCommits() -> Promise<[Commit]> {
        let request = BitbucketCommitsRequest(userName: user.name, repositorySlug: repository.uuid)
        return gitClient.send(request: request).then(execute: { result -> [Commit] in
            return result.commits
        })
    }

    private func reload(with commits: [Commit]) {
        self.commits = commits
        tableView.reloadData()
    }
}

extension CommitsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: CommitCell.self, for: indexPath)
        let commit = commits[indexPath.item]
        cell.configure(with: commit)
        return cell
    }
}

extension CommitsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
