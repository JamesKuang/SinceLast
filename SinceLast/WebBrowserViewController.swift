//
//  WebBrowserViewController.swift
//  SinceLast
//
//  Created by James Kuang on 5/12/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import WebKit

final class WebBrowserViewController: UIViewController {
    let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    let request: URLRequest

    convenience init(url: URL) {
        let request = URLRequest(url: url)
        self.init(request: request)
    }

    init(request: URLRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

        webView.navigationDelegate = self
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
}

extension WebBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let validator = WebViewNavigationActionValidator(url: url)
        guard validator.isSchemeValid else {
            decisionHandler(.allow)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }

    private struct WebViewNavigationActionValidator {
        let validScheme = "sincelast"

        let url: URL

        var isSchemeValid: Bool {
            if let scheme = url.scheme,
                scheme == validScheme,
                UIApplication.shared.canOpenURL(url) {
                return true
            }
            return false
        }
    }
}
