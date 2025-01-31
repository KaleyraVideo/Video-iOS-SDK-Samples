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
        collection.dragDelegate = self
        collection.dropDelegate = self
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
        collection.dragDelegate = self
        collection.dropDelegate = self
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

        func indexPath(for button: Button) -> IndexPath? {
            for section in 0 ..< sections.count {
                for item in 0 ..< sections[section].items.count {
                    guard sections[section].items[item] == button else { continue }
                    return .init(item: item, section: section)
                }
            }
            return nil
        }

        func button(at indexPath: IndexPath) -> Button {
            sections[indexPath.section].items[indexPath.item]
        }

        mutating func deleteItem(at indexPath: IndexPath) {
            sections[indexPath.section].items.remove(at: indexPath.item)
        }

        mutating func moveItem(_ button: Button, to destinationIndexPath: IndexPath) {
            guard let sourceIndexPath = indexPath(for: button) else { return }
            sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
            sections[destinationIndexPath.section].items.insert(button, at: destinationIndexPath.item)
        }

        mutating func insert(_ button: Button) {
            buttons.append(button)
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

    private lazy var model: ViewModel = .init(maxNumberOfItemsPerSection: traitCollection.userInterfaceIdiom == .pad ? 8 : 5, buttons: [.hangUp, .microphone])
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

        let shouldShowTitle = if collectionView == buttonsCollectionView, indexPath.section == model.numberOfSections - 1 {
            false
        } else {
            true
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ButtonCell.self)", for: indexPath) as! ButtonCell
        cell.configure(for: button, shouldShowTitle: shouldShowTitle)
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
        guard collectionView == buttonsCollectionView else { return .init(width: 68, height: 85) }
        guard indexPath.section == model.numberOfSections - 1 else { return .init(width: 68, height: 85) }
        return .init(width: 68, height: 46)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard collectionView == buttonsCollectionView else { return .zero }
        let topInset: CGFloat = section == 0 ? 10 : 0
        let bottomInset: CGFloat = section == model.numberOfSections - 1 ? 10 : 0
        return .init(top: topInset, left: 4, bottom: bottomInset, right: 4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard collectionView == buttonsCollectionView else { return .zero }
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let button = if collectionView == buttonsCollectionView {
            model.button(at: indexPath)
        } else {
            availableButtons.button(at: indexPath)
        }

        let itemProvider = NSItemProvider(object: button.identifier as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = DragItem(indexPath: indexPath, collectionView: collectionView, button: button)
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let item = session.items.first?.localObject as? DragItem else { return .init(operation: .cancel) }

        if item.collectionView == buttonsCollectionView, collectionView == item.collectionView, destinationIndexPath != nil {
            return .init(operation: .move, intent: .insertAtDestinationIndexPath)
        } else if collectionView != item.collectionView {
            return .init(operation: .copy)
        } else {
            return .init(operation: .forbidden)
        }
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        for item in coordinator.items {
            guard let dragItem = item.dragItem.localObject as? DragItem else { continue }

            if coordinator.proposal.operation == .copy {
                if dragItem.collectionView == buttonsCollectionView {
                    model.deleteItem(at: dragItem.indexPath)

                    buttonsCollectionView.performBatchUpdates {
                        buttonsCollectionView.deleteItems(at: [dragItem.indexPath])
                    }
                    availableButtons.append(button: dragItem.button)
                    let destinationIndexPath = IndexPath(item: availableButtons.numberOfItems(in: 0) - 1, section: 0)
                    availableCollectionView.performBatchUpdates {
                        availableCollectionView.insertItems(at: [destinationIndexPath])
                    }
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                } else {
                    availableButtons.deleteItem(at: dragItem.indexPath)

                    availableCollectionView.performBatchUpdates {
                        availableCollectionView.deleteItems(at: [dragItem.indexPath])
                    }
                    model.insert(dragItem.button)
                    // TODO: Crashes when trying to insert a new section
                    let destinationIndexPath = IndexPath(item: model.numberOfItems(in: 0) - 1, section: 0)

                    buttonsCollectionView.performBatchUpdates {
                        buttonsCollectionView.insertItems(at: [destinationIndexPath])
                    }
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else if coordinator.proposal.operation == .move, let destinationIndexPath = coordinator.destinationIndexPath {
                if dragItem.collectionView == buttonsCollectionView {
                    model.moveItem(dragItem.button, to: destinationIndexPath)

                    buttonsCollectionView.performBatchUpdates {
                        buttonsCollectionView.deleteItems(at: [dragItem.indexPath])
                        buttonsCollectionView.insertItems(at: [destinationIndexPath])
                    }
                }
            }
        }
    }

    private struct DragItem {
        let indexPath: IndexPath
        let collectionView: UICollectionView
        let button: Button
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
