//
//  RepositoryCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/23/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit
import Kingfisher

final class RepositoryCell: UICollectionViewCell {
    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    fileprivate let ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(ownerLabel)
        stackView.addArrangedSubview(descriptionLabel)

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

extension RepositoryCell: ConfigurableCell {
    func configure(with repository: Repository) {
        imageView.kf.indicatorType = .activity
        let modifier = AnyModifier { request in
            let keySecretProvider = OAuthKeySecretProvider()
            let scheme: AuthorizationHeaderScheme = .basic(user: keySecretProvider.key, password: keySecretProvider.secret)
            var r = request
            r.setValue(scheme.value, forHTTPHeaderField: scheme.key)
            return r
        }
        imageView.kf.setImage(with: URL(string: repository.avatarURL), options: [.requestModifier(modifier)], completionHandler: {
            (image, error, cacheType, imageUrl) in
            print(error)
        })

        titleLabel.text = repository.name
        ownerLabel.text = repository.owner.name
        descriptionLabel.text = repository.description
    }
}
