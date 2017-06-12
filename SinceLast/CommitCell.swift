//
//  CommitCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

final class CommitCell: UITableViewCell {
    fileprivate let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    fileprivate let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    fileprivate let committerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .gray
        return label
    }()

    fileprivate let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()

    fileprivate let branchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4.0
        return stackView
    }()

    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15.0
        return stackView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(avatarView)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(branchLabel)
        stackView.addArrangedSubview(horizontalStackView)

        horizontalStackView.addArrangedSubview(committerLabel)
        horizontalStackView.addArrangedSubview(timestampLabel)

        let guide = contentView.readableContentGuide
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: guide.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 0.0),
//            avatarView.widthAnchor.constraint(equalToConstant: 32.0),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 0.0),
//            stackView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10.0),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        branchLabel.text = nil
        committerLabel.text = nil
        timestampLabel.text = nil
    }
}

extension CommitCell: ConfigurableCell {
    func configure(with displayable: CommitDisplayable) {
        let commit = displayable.commit
        messageLabel.text = commit.message
        committerLabel.text = commit.author.name
        timestampLabel.text = DateFormatters.commitDisplayFormatter.string(from: commit.date)

        if let branchName = displayable.branch?.name {
            let attributedBranchName = NSAttributedString(string: branchName, attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSBackgroundColorAttributeName: UIColor.gray,
                NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline),
                ])
            branchLabel.attributedText = attributedBranchName
        }
    }
}
