//
//  SettingsCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/24/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class SettingsCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.textColor = .black
    }
}

extension SettingsCell: ConfigurableCell {
    func configure(with title: String) {
        textLabel?.text = title
    }
}
