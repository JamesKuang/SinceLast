//
//  SettingsViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/24/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    enum Section: Int, CaseCountable {
        case logout

        init(_ section: Int) {
            switch section {
            case 0: self = .logout
            default: fatalError("Unsupported section")
            }
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Settings", comment: "Settings screen navigation bar title")
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

        tableView.register(cell: SettingsCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private dynamic func tappedCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    fileprivate func logout() {

    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(section) {
        case .logout: return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: SettingsCell.self, for: indexPath)
        switch Section(indexPath.section) {
        case .logout: cell.configure(with: NSLocalizedString("Logout", comment: "Logout row text"))
        }
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(indexPath.section) {
        case .logout: logout()
        }
    }
}
