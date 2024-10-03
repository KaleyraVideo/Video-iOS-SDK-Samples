// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

final class ContactTableViewCell: UITableViewCell {

    private enum AccessibilityIdentifier: String {
        case nameLabel
        case aliasLabel
    }

    var contact: Contact? {
        didSet {
            nameLabel.text = contact?.fullName
            aliasLabel.text = contact?.alias
            avatarImageView.image = contact?.imageName.map({ .init(named: $0) }) ?? nil
        }
    }

    private let nameLabel : UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = AccessibilityIdentifier.nameLabel.rawValue
        label.textColor = Theme.Color.commonBlackColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let aliasLabel : UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = AccessibilityIdentifier.aliasLabel.rawValue
        label.textColor = Theme.Color.commonBlackColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.minimumScaleFactor = 0.2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let avatarImageView : CircleMaskedImageView = {
        let imageView = CircleMaskedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviews()
        setupContraints()
        addBackgroundView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(aliasLabel)
    }

    func setupContraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor, constant: 0),
            nameLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            nameLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10),
            contentView.centerYAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            aliasLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            aliasLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 20),
            aliasLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            aliasLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func addBackgroundView() {
        selectionStyle = .blue

        let background = UIView()
        background.backgroundColor = .clear
        background.layer.masksToBounds = true

        selectedBackgroundView = background
    }
}
