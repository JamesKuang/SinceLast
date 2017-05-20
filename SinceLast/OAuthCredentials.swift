//
//  OAuthCredentials.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol OAuthCredentials {
    var service: GitService { get }
    /// This is the raw URL. It should not be used directly.
    var authorizationURL: URL { get }
    var parameters: [String: String] { get }
}
