//
//  SettingsViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/24/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import MessageUI

protocol SettingsDisplayable {
    var title: String { get }
    var color: UIColor { get }
}

final class SettingsViewController: UIViewController {
    enum Section: Int, CaseCountable {
        case help
        case logout

        enum Help: Int, CaseCountable, SettingsDisplayable {
            case contact
            case tweet
            case rate

            init(_ row: Int) {
                switch row {
                case 0: self = .contact
                case 1: self = .tweet
                case 2: self = .rate
                default: fatalError("Unsupported row")
                }
            }

            var title: String {
                switch self {
                case .contact: return NSLocalizedString("Feedback & Feature Request", comment: "Feedback row text")
                case .tweet: return NSLocalizedString("Tweet @jamskuang", comment: "Tweet row text")
                case .rate: return NSLocalizedString("Help Rate Since Last", comment: "Rate app row text")
                }
            }

            var color: UIColor {
                return .black
            }
        }

        enum Logout: Int, CaseCountable, SettingsDisplayable {
            case logout

            init(_ row: Int) {
                switch row {
                case 0: self = .logout
                default: fatalError("Unsupported row")
                }
            }

            var title: String {
                return NSLocalizedString("Log Out", comment: "Log Out row text")
            }

            var color: UIColor {
                return .red
            }
        }

        init(_ section: Int) {
            switch section {
            case 0: self = .help
            case 1: self = .logout
            default: fatalError("Unsupported section")
            }
        }

        var count: Int {
            switch self {
            case .help: return Section.Help.count
            case .logout: return Section.Logout.count
            }
        }

        func rowRisplayable(for row: Int) -> SettingsDisplayable {
            switch self {
            case .help: return Section.Help(row)
            case .logout: return Section.Logout(row)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    private dynamic func tappedCloseButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    fileprivate func sendFeedback() {
        guard MFMailComposeViewController.canSendMail() else { return }
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([Links.contactEmail])
        present(controller, animated: true, completion: nil)
    }

    fileprivate func composeTweet(from indexPath: IndexPath) {
        guard let url = URL(string: Links.twitterURLJames) else { fatalError("Twitter URL is malformed") }
        UIApplication.shared.open(url, options: [:], completionHandler: { success in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
    }

    fileprivate func rateApp(from indexPath: IndexPath) {
        guard let url = URL(string: Links.reviewURL) else { fatalError("Review URL is malformed") }
        UIApplication.shared.open(url, options: [:], completionHandler: { success in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
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
        return Section(section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(of: SettingsCell.self, for: indexPath)
        let row = Section(indexPath.section).rowRisplayable(for: indexPath.row)
        cell.configure(with: row)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(section) {
        case .help: return NSLocalizedString("Help", comment: "Help section title in Settings")
        case .logout: return currentUser.name
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(indexPath.section) {
        case .help:
            switch Section.Help(indexPath.row) {
            case .contact: sendFeedback()
            case .tweet: composeTweet(from: indexPath)
            case .rate: rateApp(from: indexPath)
            }
        case .logout: logout()
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController {
    enum Links {
        static let contactEmail = "incyc.apps@gmail.com"
        static let twitterURLJames = "https://twitter.com/jamskuang"
        static let reviewURL = "itms-apps://itunes.apple.com/us/app/id1234428549?action=write-review&mt=8"
    }
}
