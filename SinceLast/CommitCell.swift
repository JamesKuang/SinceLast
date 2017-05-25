//
//  CommitCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class CommitCell: UICollectionViewCell {
    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    fileprivate let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()

    fileprivate let committerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    fileprivate let shaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .gray
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4.0
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(committerLabel)
        stackView.addArrangedSubview(shaLabel)

        let guide = contentView.readableContentGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: guide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 32.0),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10.0),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommitCell: ConfigurableCell {
    func configure(with commit: Commit) {
        messageLabel.text = commit.message
        committerLabel.text = commit.author.name
        shaLabel.text = commit.shortSHA
    }
}
