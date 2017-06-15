//
//  GitService.swift
//  SinceLast
//
//  Created by James Kuang on 5/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

enum GitService {
    case github
    case bitbucket

    var name: String {
        switch self {
        case .github: return "Github"
        case .bitbucket: return "Bitbucket"
        }
    }

    var apiBaseURL: String {
        switch self {
        case .github: return "https://api.github.com/graphql"
        case .bitbucket: return "https://api.bitbucket.org"
        }
    }

    var oAuthBaseURL: String {
        switch self {
        case .github: return "http://github.com"
        case .bitbucket: return "https://bitbucket.org"
        }
    }

    var logoImage: UIImage {
        switch self {
        case .github: return #imageLiteral(resourceName: "github_logo")
        case .bitbucket: return #imageLiteral(resourceName: "bitbucket_logo")
        }
    }

    var isSupported: Bool {
        switch self {
        case .github: return true
        case .bitbucket: return true
        }
    }

    init?(serviceName: String) {
        switch serviceName {
        case "github": self = .github
        case "bitbucket": self = .bitbucket
        default: return nil
        }
    }
}
