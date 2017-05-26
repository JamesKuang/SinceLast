//
//  ThemeColors.swift
//  SinceLast
//
//  Created by James Kuang on 5/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

enum ThemeColor {
    case darkOrange     // #ff6500
    case orange         // #ffa500
    case lightOrange    // #ffe500

    var color: UIColor {
        switch self {
        case .darkOrange: return UIColor(displayP3Red: 1.0, green: 0.396, blue: 0.0, alpha: 1.0)
        case .orange: return UIColor(displayP3Red: 1.0, green: 0.647, blue: 0.0, alpha: 1.0)
        case .lightOrange: return UIColor(displayP3Red: 1.0, green: 0.898, blue: 0.0, alpha: 1.0)
        }
    }
}
