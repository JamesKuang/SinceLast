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

    fileprivate let currentUser: User

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let footerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            label.text = "Since Last v\(version) - Made with ❤️ and ☕️ by James Kuang"
        }
        label.sizeToFit()
        return label
    }()

    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)

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
        tableView.tableFooterView = footerLabel
    }

    private dynamic func tappedCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    fileprivate func logout() {
        NotificationCenter.default.post(name: .didLogoutGitService, object: self)
        dismiss(animated: true)
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
        case .logout:
            cell.configure(with: NSLocalizedString("Log Out", comment: "Log Out row text"))
            cell.textLabel?.textColor = .red
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(section) {
        case .logout: return currentUser.name
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(indexPath.section) {
        case .logout: logout()
        }
    }
}
