//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    private lazy var labelsContainer: UIView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 4
        stack.disableAutoresizingMasks()
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.disableAutoresizingMasks()
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.disableAutoresizingMasks()
        return label
    }()

    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "chat"), for: .normal)
        button.addTarget(self, action: #selector(chatButtonTouched(_:)), for: .touchUpInside)
        button.disableAutoresizingMasks()
        return button
    }()

    private lazy var phoneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "phone"), for: .normal)
        button.addTarget(self, action: #selector(phoneButtonTouched(_:)), for: .touchUpInside)
        button.disableAutoresizingMasks()
        return button
    }()

    private lazy var buttonsContainer: UIView = {
        let stack = UIStackView(arrangedSubviews: [chatButton, phoneButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10
        stack.alignment = .center
        stack.disableAutoresizingMasks()
        return stack
    }()

    // MARK: - Events

    var onChatButtonTap: ((UITableViewCell) -> Void)?
    var onPhoneButtonTap: ((UITableViewCell) -> Void)?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

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
        contentView.addSubview(labelsContainer)
        contentView.addSubview(buttonsContainer)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            labelsContainer.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            labelsContainer.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            labelsContainer.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            labelsContainer.rightAnchor.constraint(equalTo: buttonsContainer.leftAnchor, constant: 8),
            buttonsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            buttonsContainer.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    // MARK: - Actions

    @objc
    private func chatButtonTouched(_ sender: UIButton) {
        onChatButtonTap?(self)
    }

    @objc
    private func phoneButtonTouched(_ sender: UIButton) {
        onPhoneButtonTap?(self)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        subtitleLabel.text = nil
        onChatButtonTap = nil
        onPhoneButtonTap = nil
    }
}
