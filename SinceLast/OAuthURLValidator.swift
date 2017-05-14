//
//  OAuthURLValidator.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct OAuthURLValidator {
    let url: URL
    let urlComponents: URLComponents?
    let expectedScheme: String

    init(url: URL, expectedScheme: String) {
        self.url = url
        self.urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        self.expectedScheme = expectedScheme
    }

    var result: Result<String> {
        guard let components = urlComponents else { return .failure(NilError()) }
        guard let scheme = components.scheme, scheme == expectedScheme else { return .failure(ValidationError("Scheme does not match")) }
        guard let code = accessCode else { return .failure(ValidationError("Missing access code")) }
        return .success(code)
    }

    private var accessCode: String? {
        guard let queryItems = urlComponents?.queryItems else { return nil }
        let codeItem = queryItems.first { $0.name == "code" }
        return codeItem?.value
    }
}
