//
//  CommitCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import NSDateTimeAgo

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

    fileprivate let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()

    fileprivate let branchLabel: ContentInsetLabel = {
        let label = ContentInsetLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 8.0
        label.contentInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        return label
    }()

    fileprivate let branchTrailingFillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4.0
        return stackView
    }()

    private let branchHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        return stackView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(avatarView)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(branchHorizontalStackView)

        branchHorizontalStackView.addArrangedSubview(branchLabel)
        branchHorizontalStackView.addArrangedSubview(branchTrailingFillerView)
        branchHorizontalStackView.addArrangedSubview(timestampLabel)

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
        timestampLabel.text = nil
    }

    func updateBranchName(_ branchName: String?) {
        if let branchName = branchName {
            branchLabel.text = branchName
            branchLabel.isHidden = false
        } else {
            branchLabel.text = nil
            branchLabel.isHidden = true
        }
    }
}

extension CommitCell: ConfigurableCell {
    func configure(with displayable: CommitDisplayable) {
        let commit = displayable.commit
        messageLabel.text = commit.message
        timestampLabel.text = commit.date.timeAgo
        updateBranchName(displayable.branch?.name)
    }
}
