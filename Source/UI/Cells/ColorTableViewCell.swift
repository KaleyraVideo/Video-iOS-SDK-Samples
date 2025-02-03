// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class ColorTableViewCell : UITableViewCell {

    @Proxy(\.label.text)
    var title: String?

    @Proxy(\.colorWell.selectedColor)
    var color: UIColor?

    var onColorChanged: ((UIColor?) -> Void)?

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textAlignment = .left
        return label
    }()

    private lazy var colorWell: UIColorWell = {
        let view = UIColorWell()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(onColorChanged(sender:)), for: .valueChanged)
        return view
    }()

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
        contentView.addSubview(colorWell)
    }

    private func setupConstraints() {
        setupLabelConstraints()
        setupColorWellConstraints()
    }

    private func setupLabelConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7)
        ])
    }

    private func setupColorWellConstraints() {
        NSLayoutConstraint.activate([
            colorWell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorWell.heightAnchor.constraint(equalTo: label.heightAnchor, multiplier: 0.8),
            colorWell.widthAnchor.constraint(equalTo: label.heightAnchor, multiplier: 0.8),
            colorWell.centerYAnchor.constraint(equalTo: label.centerYAnchor),
        ])
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        title = nil
        color = nil
    }

    // MARK: - Action

    @objc
    private func onColorChanged(sender: UIColorWell) {
        onColorChanged?(sender.selectedColor)
    }
}
