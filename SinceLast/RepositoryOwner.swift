//
//  RepositoryOwner.swift
//  SinceLast
//
//  Created by James Kuang on 5/27/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum RepositoryOwner {
    case user(User)
    case team(Team)

    var uuid: String {
        switch self {
        case .user(let user): return user.uuid
        case .team(let team): return team.uuid
        }
    }
}
