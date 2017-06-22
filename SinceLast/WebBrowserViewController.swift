//
//  WebBrowserViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/12/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import WebKit
import OnePasswordExtension

protocol WebBrowserViewControllerDelegate: class {
    func controllerDidClose(_ controller: WebBrowserViewController)
}

/// This class only used for testing.
final class WebBrowserViewController: UIViewController {
    let webView: WKWebView = {
        let contentController = WKUserContentController()
        let source = "var x = document.getElementsByClassName('signup-link'); for (i = 0; i < x.length; i++) { x[i].parentNode.removeChild(x[i]); }"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    let request: URLRequest

    weak var delegate: WebBrowserViewControllerDelegate?

    convenience init(url: URL) {
        let request = URLRequest(url: url)
        self.init(request: request)
    }

    init(request: URLRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)

        title = request.url?.host

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        webView.navigationDelegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Close navigation bar button"), style: .done, target: self, action: #selector(close))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "onepassword-navbar"), style: .plain, target: self, action: #selector(findLoginFrom1Password(_:)))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParentViewController {
            webView.load(request)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    dynamic fileprivate func close() {
        webView.stopLoading()
        delegate?.controllerDidClose(self)
    }

    dynamic private func findLoginFrom1Password(_ sender: UIBarButtonItem) {
        OnePasswordExtension.shared().fillItem(intoWebView: webView, for: self, sender: sender, showOnlyLogins: true, completion: { success, error in
            if !success, let error = error {
                print("Failed to fill into webview: <\(error)>")
            }
        })
    }
}

extension WebBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let signUpPathValidator = BitbucketSignupPathValidator(url: url)
        if signUpPathValidator.isValid {
            decisionHandler(.cancel)
            return
        }

        let schemeValidator = WebViewNavigationActionValidator(url: url, expectedScheme: "sincelast")
        guard schemeValidator.isSchemeValid else {
            decisionHandler(.allow)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        close()
        decisionHandler(.cancel)
    }
}

private struct WebViewNavigationActionValidator {
    let url: URL
    let expectedScheme: String
    let urlOpener: ApplicationURLOpening

    var isSchemeValid: Bool {
        if let scheme = url.scheme,
            scheme == expectedScheme,
            urlOpener.canOpenURL(url) {
            return true
        }
        return false
    }

    init(url: URL, expectedScheme: String, urlOpener: ApplicationURLOpening = UIApplication.shared) {
        self.url = url
        self.expectedScheme = expectedScheme
        self.urlOpener = urlOpener
    }
}

private struct BitbucketSignupPathValidator {
    let url: URL

    var isValid: Bool {
        if let host = url.host,
            host == "bitbucket.org",
            url.lastPathComponent == "signup" {
            return true
        }
        return false
    }
}
