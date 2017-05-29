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

    private let headerView: HeaderView = {
        let view = HeaderView()
        view.autoresizingMask = [.flexibleWidth]
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ThemeColor.darkOrange.color
        tableView.refreshControl = refreshControl
        return tableView
    }()

    fileprivate let currentUser: User
    fileprivate let repositoryOwner: RepositoryOwner
    fileprivate let repository: Repository
    fileprivate var commits: [Commit] = []

    init(client: GitClient, currentUser: User, repositoryOwner: RepositoryOwner, repository: Repository) {
        self.gitClient = client
        self.currentUser = currentUser
        self.repositoryOwner = repositoryOwner
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
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 50.0)
        
        fetchData()
    }

    private func fetchData() {
        let _ = retrieveCommits()
            .then { commits in
                self.reload(with: commits)
            }.catch { error in
                print(error)
        }

        let _ = retrievePullRequests().then { pullRequests -> Void in
            let filtered = pullRequests.filter { $0.author != self.currentUser }
            print(filtered.count)
            self.headerView.update(with: filtered.count)
        }
    }

    private func retrieveCommits() -> Promise<[Commit]> {
        let request = BitbucketCommitsRequest(userName: repositoryOwner.uuid, repositorySlug: repository.uuid)
        return gitClient.send(request: request).then(execute: { result -> [Commit] in
            return result.commits
        })
    }

    private func retrievePullRequests() -> Promise<[PullRequest]> {
        let request = BitbucketPullRequestsRequest(userName: repositoryOwner.uuid, repositorySlug: repository.uuid)
        return gitClient.send(request: request).then(execute: { result -> [PullRequest] in
            return result.pullRequests
        })
    }

    private func reload(with commits: [Commit]) {
        self.commits = commits
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    private dynamic func refreshControlValueChanged(_ sender: UIRefreshControl) {
        fetchData()
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

private final class HeaderView: UIView {
    private let leftLabel: UILabel = {
        let leftLabel = UILabel()
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.font = UIFont.preferredFont(forTextStyle: .body)
        leftLabel.textColor = .gray
        leftLabel.text = NSLocalizedString("Open Pull Requests:", comment: "Open pull requests label text")
        return leftLabel
    }()

    private let rightLabel: UILabel = {
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        rightLabel.text = NSLocalizedString("N/A", comment: "Not Available acryonym text")
        return rightLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(leftLabel)
        addSubview(rightLabel)

        let padding: CGFloat = 10.0
        let widthConstraints = [
            leftLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: padding),
            rightLabel.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: padding),
            rightLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -padding),
            ]
        widthConstraints.forEach { $0.priority = 999 }

        NSLayoutConstraint.activate(widthConstraints + [
            leftLabel.topAnchor.constraint(equalTo: topAnchor),
            leftLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightLabel.topAnchor.constraint(equalTo: topAnchor),
            rightLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with count: Int) {
        rightLabel.text = String(count)
        rightLabel.textColor = count > 0 ? ThemeColor.darkOrange.color : .black
    }
}
