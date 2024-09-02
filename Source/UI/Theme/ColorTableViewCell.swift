// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

enum ThemeCustomCellCase {
    case color
    case keyboardAppearance
    case bool
    case font
    case barStyle
    case number
}

class ColorTableViewCell : UITableViewCell {

    var title: String? {
        get {
            label.text
        }

        set {
            label.text = newValue
        }
    }

    var color: UIColor? {
        get {
            colorPreview.backgroundColor
        }

        set {
            colorPreview.backgroundColor = newValue
        }
    }

    private let label : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textAlignment = .left
        return label
    }()

    lazy var colorPreview: ColorPreviewView = {
        let view = ColorPreviewView()
        view.borderColor = UIColor.dynamicColor(light: .black, dark: .white)
        view.borderWidth = 1
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        colorPreview.borderColor = UIColor.dynamicColor(light: .black, dark: .white)
    }

    // MARK: - Setup

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        contentView.addSubview(label)
        contentView.addSubview(colorPreview)
    }

    private func setupConstraints() {
        setupLabelConstraints()
        setupColorPreviewConstraints()
    }

    private func setupLabelConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7)
        ])
    }

    private func setupColorPreviewConstraints() {
        NSLayoutConstraint.activate([
            colorPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorPreview.heightAnchor.constraint(equalTo: label.heightAnchor, multiplier: 0.8),
            colorPreview.widthAnchor.constraint(equalTo: label.heightAnchor, multiplier: 0.8),
            colorPreview.centerYAnchor.constraint(equalTo: label.centerYAnchor),
        ])
    }

    func setUpLabelFont(font: UIFont) {
        label.font = font
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        title = nil
        color = nil
    }
}
