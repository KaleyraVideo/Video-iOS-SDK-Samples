// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

class UserCell: UITableViewCell {

    var contact: Contact? {
        didSet {

            if let imageName = contact?.imageName {
                contactImage.image = UIImage(named: imageName)
            }

            contactNameLabel.text = contact?.fullName
            contactAliasLabel.text = contact?.alias
        }
    }

    private let contactNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.accessibilityIdentifier = "__contact_name_label__"
        lbl.textColor = Theme.Color.commonBlackColor
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.minimumScaleFactor = 0.6
        lbl.adjustsFontSizeToFitWidth = true
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 0
        return lbl
    }()

    private let contactAliasLabel : UILabel = {
        let lbl = UILabel()
        lbl.accessibilityIdentifier = "__contact_alias_label__"
        lbl.textColor = Theme.Color.commonBlackColor
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.minimumScaleFactor = 0.2
        lbl.textAlignment = .left
        lbl.adjustsFontSizeToFitWidth = true
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 0
        return lbl
    }()

    private let contactImage : CircleMaskedImageView = {
        let imgView = CircleMaskedImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubviews()
        setupContraints()
        addBackgroundView()
    }

    func addSubviews() {
        contentView.addSubview(contactImage)
        contentView.addSubview(contactNameLabel)
        contentView.addSubview(contactAliasLabel)
    }

    func setupContraints() {
        contactImage.translatesAutoresizingMaskIntoConstraints = false
        contactNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contactAliasLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contactImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            contactImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            contactImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            contactImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contactImage.widthAnchor.constraint(equalTo: contactImage.heightAnchor, constant: 0),
            contactNameLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            contactNameLabel.leftAnchor.constraint(equalTo: contactImage.rightAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: contactNameLabel.rightAnchor, constant: 10),
            contentView.centerYAnchor.constraint(equalTo: contactNameLabel.bottomAnchor, constant: 10),
            contactAliasLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            contactAliasLabel.leftAnchor.constraint(equalTo: contactImage.rightAnchor, constant: 20),
            contactAliasLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            contactAliasLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func addBackgroundView() {
        selectionStyle = .blue

        let cellBg = UIView()
        cellBg.backgroundColor = .clear
        cellBg.layer.masksToBounds = true

        selectedBackgroundView = cellBg
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if SAMPLE_CUSTOMIZABLE_THEME
extension UserCell: Themable {

    func themeChanged(theme: AppTheme) {
        let bgColor = theme.primaryBackgroundColor.toUIColor()
        backgroundColor = bgColor

        let font = theme.font != nil ? theme.font!.toUIFont() : UIFont.boldSystemFont(ofSize: 16)
        let secondaryFont = theme.secondaryFont != nil ? theme.secondaryFont!.toUIFont() : UIFont.systemFont(ofSize: 14)

        contactNameLabel.font = font
        contactAliasLabel.font = secondaryFont

        contactNameLabel.textColor = bgColor.isLight ? .black : .white
        contactAliasLabel.textColor = bgColor.isLight ? .black : .white
    }
}
#endif
