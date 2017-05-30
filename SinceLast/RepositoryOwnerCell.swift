//
//  RepositoryOwnerCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/29/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class RepositoryOwnerCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
    }
}

extension RepositoryOwnerCell: ConfigurableCell {
    func configure(with repositoryOwner: RepositoryOwner) {
        textLabel?.text = repositoryOwner.name
    }
}
