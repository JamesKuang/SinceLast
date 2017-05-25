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

    let servicesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
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

        view.addSubview(servicesStackView)

        NSLayoutConstraint.activate([
            servicesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            servicesStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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

        let pastelView = PastelView(frame: view.bounds)

        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight

        // Custom Duration
        pastelView.animationDuration = 3.0

        // Custom Color
//        pastelView.setPastelGradient(.warmFlame)
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }

    private func makeSignInButton(for serviceAuth: OAuthCredentials) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.setTitle(serviceAuth.service.name, for: .normal)
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
