//
//  WebBrowserViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/12/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import WebKit

protocol WebBrowserViewControllerDelegate: class {
    func controllerDidClose(_ controller: WebBrowserViewController)
}

final class WebBrowserViewController: UIViewController {
    let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
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
}

extension WebBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let validator = WebViewNavigationActionValidator(url: url, expectedScheme: "sincelast")
        guard validator.isSchemeValid else {
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
