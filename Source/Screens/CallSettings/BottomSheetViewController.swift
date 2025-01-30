// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

@available(iOS 15.0, *)
final class BottomSheetViewController: UIViewController {

    private lazy var buttonsCollectionView: UICollectionView = {
        let collection = IntrinsicContentSizeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = true
        collection.register(ButtonCell.self, forCellWithReuseIdentifier: "\(ButtonCell.self)")
        collection.backgroundColor = .clear
        return collection
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(rgb: 0xEEEEEE)
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(containerView)
        view.addSubview(buttonsCollectionView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: buttonsCollectionView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: buttonsCollectionView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: buttonsCollectionView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: buttonsCollectionView.bottomAnchor),
            buttonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 14),
            buttonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -14),
            buttonsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "\(ButtonCell.self)", for: indexPath)
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 68, height: 85)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

@available(iOS 15.0, *)
final class ButtonCell: UICollectionViewCell {

    private lazy var button: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 18
        config.contentInsets = .init(top: 12, leading: 4, bottom: 12, trailing: 4)
        config.titleAlignment = .center
        config.titleLineBreakMode = .byTruncatingTail
        config.image = UIImage(systemName: "questionmark")
        config.attributedTitle = .init("Title",
                                       attributes: .init([.foregroundColor : UIColor(rgb: 0x1B1B1B),
                                                          .font : UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12))]))
        config.background.customView = ImageTrackingBackgroundView()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(rgb: 0x1B1B1B)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
    }
}

private final class ImageTrackingBackgroundView: UIView {

    private lazy var decorationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 18
        view.backgroundColor = .init(rgb: 0xE2E2E2)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(decorationView)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        guard let button = newSuperview?.superview as? UIButton else { return }

        setupConstraintsToImageViewIfNeeded(button)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        guard let button = superview?.superview as? UIButton else { return }

        setupConstraintsToImageViewIfNeeded(button)
    }

    private func setupConstraintsToImageViewIfNeeded(_ button: UIButton) {
        guard let imageView = button.imageView else { return }
        guard imageView.isDescendant(of: button) else { return }
        guard imageView.image != nil else { return }
        guard isDescendant(of: button) else { return }
        guard imageView.constraints.isEmpty else { return }

        NSLayoutConstraint.activate([
            decorationView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            decorationView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            decorationView.widthAnchor.constraint(equalToConstant: 46),
            decorationView.heightAnchor.constraint(equalTo: decorationView.widthAnchor)
        ])
    }
}

private final class IntrinsicContentSizeCollectionView: UICollectionView {

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        contentSize
    }
}
