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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.itemSize = CGSize(width: self.view.bounds.width, height: 80.0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
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

        collectionView.register(cell: CommitCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
        collectionView.reloadData()
    }
}

extension CommitsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(of: CommitCell.self, for: indexPath)
        let commit = commits[indexPath.item]
        cell.configure(with: commit)
        return cell
    }
}

extension CommitsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
