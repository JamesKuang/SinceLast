//
//  GitServicesAuthorizationViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import SafariServices

final class GitServicesAuthorizationViewController: UIViewController {
    let services: [GitService]

    let servicesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var signInButtons: [UIButton] {
        return servicesStackView.arrangedSubviews.flatMap { $0 as? UIButton }
    }

    init(services: [GitService]) {
        self.services = services
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white

        view.addSubview(servicesStackView)

        NSLayoutConstraint.activate([
            servicesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            servicesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])

        let signInButtons = self.services.map { self.makeSignInButton(for: $0) }
        signInButtons.forEach { button in
            self.servicesStackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(tappedSignIn(sender:)), for: .touchUpInside)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func makeSignInButton(for service: GitService) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.setTitle(service.name, for: .normal)
        return button
    }

    dynamic func tappedSignIn(sender: UIButton) {
        guard let index = signInButtons.index(of: sender) else { fatalError("Button not found") }
        let service = services[index]
        startAuthentication(for: service)
    }

    private func startAuthentication(for service: GitService) {
        let oAuth = OAuth(credentials: service.oAuthCredentials)
        print("\(oAuth.fullAuthURL)")
        let controller = SFSafariViewController(url: oAuth.fullAuthURL)
        present(controller, animated: true, completion: nil)
    }
}

