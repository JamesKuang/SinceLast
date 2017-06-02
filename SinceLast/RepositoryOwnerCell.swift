//
//  RepositoryOwnerCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/29/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class RepositoryOwnerCell: UITableViewCell {
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        contentView.addSubview(titleLabel)

        let guide = contentView.readableContentGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}

extension RepositoryOwnerCell: ConfigurableCell {
    func configure(with repositoryOwner: User) {
        titleLabel.text = repositoryOwner.name
    }
}



final class FavoriteCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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

extension FavoriteCell: ConfigurableCell {
    func configure(with repository: FavoriteRepository) {
        textLabel?.text = repository.name
    }
}
