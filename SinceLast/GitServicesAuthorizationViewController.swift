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

    private let backgroundView: PastelView = {
        let pastelView = PastelView()
        pastelView.translatesAutoresizingMaskIntoConstraints = false
        pastelView.animationDuration = 3.0
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight

        let colors: [ThemeColor] = [.darkOrange, .orange, .lightOrange]
        pastelView.setColors(colors.map { $0.color })
        return pastelView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "commit"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let servicesStackView: UIStackView = {
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
        view.addSubview(imageView)
        view.addSubview(servicesStackView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),
            servicesStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.0),
            servicesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func makeSignInButton(for serviceAuth: OAuthCredentials) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.setImage(serviceAuth.service.logoImage.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .white

        button.layer.cornerRadius = 8.0
        button.layer.borderWidth = 1.0

        button.isEnabled = serviceAuth.service.isSupported

        let color = UIColor.white
        if button.isEnabled {
            button.layer.borderColor = color.cgColor
        } else {
            let fadedColor = color.withAlphaComponent(0.6)
            button.layer.borderColor = fadedColor.cgColor

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = NSLocalizedString("Coming soon", comment: "Coming soon label for Git service")
            label.textColor = fadedColor
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

        addMotionEffect(to: button)

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

    private func addMotionEffect(to view: UIView) {
        let effectValue = 10
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = -effectValue
        horizontalEffect.maximumRelativeValue = effectValue
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -effectValue
        verticalEffect.maximumRelativeValue = effectValue

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalEffect, verticalEffect]
        view.addMotionEffect(group)
    }
}

extension GitServicesAuthorizationViewController: WebBrowserViewControllerDelegate {
    func controllerDidClose(_ controller: WebBrowserViewController) {
        dismiss(animated: true)
    }
}
