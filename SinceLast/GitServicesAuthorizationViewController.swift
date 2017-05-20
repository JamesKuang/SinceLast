//
//  GitServicesAuthorizationViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class GitServicesAuthorizationViewController: UIViewController {
    let services: [GitServiceAuthorizing]

    let servicesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var signInButtons: [UIButton] {
        return servicesStackView.arrangedSubviews.flatMap { $0 as? UIButton }
    }

    init(services: [GitServiceAuthorizing]) {
        self.services = services
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Git Authorization", comment: "Git Services authorization navigation bar title")
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

    private func makeSignInButton(for serviceAuth: GitServiceAuthorizing) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.setTitle(serviceAuth.service.name, for: .normal)
        return button
    }

    dynamic func tappedSignIn(sender: UIButton) {
        guard let index = signInButtons.index(of: sender) else { fatalError("Button not found") }
        let service = services[index]
        startAuthentication(for: service)
    }

    private func startAuthentication(for service: GitServiceAuthorizing) {
        let oAuth = OAuth(credentials: service.oAuthCredentials)
        print("\(oAuth.fullAuthURL)")
        let controller = WebBrowserViewController(url: oAuth.fullAuthURL)
        controller.delegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true)
    }
}

extension GitServicesAuthorizationViewController: WebBrowserViewControllerDelegate {
    func controllerDidClose(_ controller: WebBrowserViewController) {
        dismiss(animated: true)
    }
}
