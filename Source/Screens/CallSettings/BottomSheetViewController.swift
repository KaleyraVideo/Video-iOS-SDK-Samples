// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class BottomSheetViewController: UIViewController {

    private lazy var availableCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
        collection.register(ButtonCell.self, forCellWithReuseIdentifier: "\(ButtonCell.self)")
        collection.backgroundColor = .clear
        return collection
    }()

    private lazy var buttonsCollectionView: UICollectionView = {
        let collection = IntrinsicContentSizeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
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

    private struct ViewModel {

        private struct Section {
            var items: [Button]
        }

        var maxNumberOfItemsPerSection: Int {
            didSet {
                updateSections()
            }
        }

        private(set) var buttons: [Button] {
            didSet {
                updateSections()
            }
        }

        var numberOfSections: Int {
            let (quotient, reminder) = buttons.count.quotientAndRemainder(dividingBy: maxNumberOfItemsPerSection)
            return reminder != 0 ? quotient + 1 : quotient
        }

        private var sections: [Section] = []

        init(maxNumberOfItemsPerSection: Int, buttons: [Button]) {
            self.maxNumberOfItemsPerSection = maxNumberOfItemsPerSection
            self.buttons = buttons
            updateSections()
        }

        private mutating func updateSections() {
            var sections = [Section](repeating: .init(items: []), count: numberOfSections)

            for i in 0 ..< buttons.count {
                sections[i / maxNumberOfItemsPerSection].items.append(buttons[i])
            }

            self.sections = sections.reversed()
        }

        func numberOfItems(in section: Int) -> Int {
            sections[section].items.count
        }

        func button(at indexPath: IndexPath) -> Button {
            sections[indexPath.section].items[indexPath.item]
        }

        mutating func deleteItem(at indexPath: IndexPath) {
            sections[indexPath.section].items.remove(at: indexPath.item)
        }
    }

    private struct AvailableButtons {

        private(set) var buttons: [Button]

        var numberOfSections: Int { 1 }

        init(buttons: [Button]) {
            self.buttons = buttons
        }

        func numberOfItems(in section: Int) -> Int {
            buttons.count
        }

        func button(at indexPath: IndexPath) -> Button {
            buttons[indexPath.item]
        }

        mutating func append(button: Button) {
            buttons.append(button)
        }

        mutating func deleteItem(at indexPath: IndexPath) {
            buttons.remove(at: indexPath.item)
        }
    }

    private lazy var model: ViewModel = .init(maxNumberOfItemsPerSection: traitCollection.userInterfaceIdiom == .pad ? 8 : 5, buttons: Button.allCases)
    private lazy var availableButtons = AvailableButtons(buttons: Button.allCases.filter({ !model.buttons.contains($0) }))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationItem()
        setupHierarchy()
        setupConstraints()
    }

    private func setupNavigationItem() {
        navigationItem.title = "Custom bottom sheet"
        navigationItem.rightBarButtonItem = editButtonItem
    }

    private func setupHierarchy() {
        view.addSubview(availableCollectionView)
        view.addSubview(containerView)
        view.addSubview(buttonsCollectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            availableCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            availableCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            availableCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            availableCollectionView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.topAnchor.constraint(equalTo: buttonsCollectionView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: buttonsCollectionView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: buttonsCollectionView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: buttonsCollectionView.bottomAnchor),
            buttonsCollectionView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 14),
            buttonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -14),
            buttonsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        buttonsCollectionView.isEditing = editing
    }

    private func deleteButton(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard collectionView == buttonsCollectionView else { return }

        let button = model.button(at: indexPath)
        availableButtons.append(button: button)
        availableCollectionView.performBatchUpdates {
            availableCollectionView.insertItems(at: [.init(item: availableButtons.buttons.endIndex - 1, section: 0)])
        }

        model.deleteItem(at: indexPath)

        buttonsCollectionView.performBatchUpdates {
            buttonsCollectionView.deleteItems(at: [indexPath])
        }
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == buttonsCollectionView {
            model.numberOfSections
        } else {
            availableButtons.numberOfSections
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == buttonsCollectionView {
            model.numberOfItems(in: section)
        } else {
            availableButtons.numberOfItems(in: section)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let button = if collectionView == buttonsCollectionView {
            model.button(at: indexPath)
        } else {
            availableButtons.button(at: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ButtonCell.self)", for: indexPath) as! ButtonCell
        cell.configure(for: button)
        cell.deleteAction = { [weak self] cell in
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            self?.deleteButton(in: collectionView, at: indexPath)
        }
        return cell
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 68, height: 85)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard collectionView == buttonsCollectionView else { return .zero }
        return .init(top: 10, left: 4, bottom: 0, right: 4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard collectionView == buttonsCollectionView else { return .zero }
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4
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
