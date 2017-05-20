//
//  GitService.swift
//  SinceLast
//
//  Created by James Kuang on 5/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum GitService {
    case bitbucket

    var name: String {
        switch self {
        case .bitbucket: return "Bitbucket"
        }
    }

    var apiBaseURL: String {
        switch self {
        case .bitbucket: return "https://api.bitbucket.org"
        }
    }

    var oAuthBaseURL: String {
        switch self {
        case .bitbucket: return "https://bitbucket.org"
        }
    }
}
