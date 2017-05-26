//
//  GitServicesAuthorizationViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import Pastel

final class GitServicesAuthorizationViewController: UIViewController {
    let credentials: [OAuthCredentials]

    let backgroundView: PastelView = {
        let pastelView = PastelView()
        pastelView.translatesAutoresizingMaskIntoConstraints = false
        pastelView.animationDuration = 3.0
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight

        let colors: [ThemeColor] = [.darkOrange, .orange, .lightOrange]
        pastelView.setColors(colors.map { $0.color })
        return pastelView
    }()

    let servicesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10.0
        stackView.distribution = .fillEqually
        return stackView
    }()

    var signInButtons: [UIButton] {
        return servicesStackView.arrangedSubviews.flatMap { $0 as? UIButton }
    }

    init(credentials: [OAuthCredentials]) {
        self.credentials = credentials
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Git Authorization", comment: "Git Services authorization navigation bar title")
        view.backgroundColor = .white

        view.insertSubview(backgroundView, at: 0)
        view.addSubview(servicesStackView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            servicesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            servicesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            servicesStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            ])

        let signInButtons = self.credentials.map { self.makeSignInButton(for: $0) }
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
        backgroundView.startAnimation()
    }

    private func makeSignInButton(for serviceAuth: OAuthCredentials) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.setImage(serviceAuth.service.logoImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isEnabled = serviceAuth.service.isSupported
        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.darkGray.cgColor
        return button
    }

    dynamic func tappedSignIn(sender: UIButton) {
        guard let index = signInButtons.index(of: sender) else { fatalError("Button not found") }
        let credentials = self.credentials[index]
        startAuthentication(with: credentials)
    }

    private func startAuthentication(with credentials: OAuthCredentials) {
        let oAuth = OAuth(credentials: credentials)
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
