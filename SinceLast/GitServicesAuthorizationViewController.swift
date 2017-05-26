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

        view.backgroundColor = .white

        view.insertSubview(backgroundView, at: 0)
        view.addSubview(servicesStackView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            servicesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            servicesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80.0),
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func makeSignInButton(for serviceAuth: OAuthCredentials) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.setImage(serviceAuth.service.logoImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.black.cgColor

        button.isEnabled = serviceAuth.service.isSupported

        if !button.isEnabled {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = NSLocalizedString("Coming soon", comment: "Coming soon label for Git service")
            button.addSubview(label)

            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4.0),
                label.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -2.0),
                ])
        }

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 100.0),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 2.5),
        ])

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
