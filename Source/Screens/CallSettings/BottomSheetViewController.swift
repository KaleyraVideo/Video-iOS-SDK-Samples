// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class BottomSheetViewController: UIViewController {

    private lazy var inactiveButtonsCollectionView: IntrinsicContentSizeCollectionView = .init(delegate: self)

    private lazy var activeButtonsCollectionView: IntrinsicContentSizeCollectionView = .init(delegate: self)

    private lazy var inactiveButtonsDataSource: UICollectionViewDiffableDataSource<Int, Button> = {
        .init(collectionView: inactiveButtonsCollectionView) { collectionView, indexPath, button in
            let cell = collectionView.dequeueReusableCell(ButtonCell.self, for: indexPath)
            cell.configure(for: button, shouldShowTitle: true)
            return cell
        }
    }()

    private lazy var activeButtonsDataSource: UICollectionViewDiffableDataSource<Int, Button> = {
        .init(collectionView: activeButtonsCollectionView) { collectionView, indexPath, button in
            let cell = collectionView.dequeueReusableCell(ButtonCell.self, for: indexPath)
            cell.configure(for: button, shouldShowTitle: indexPath.section != collectionView.numberOfSections - 1)
            cell.deleteAction = { [weak self] cell in
                self?.deleteCell(cell, from: collectionView)
            }
            return cell
        }
    }()

    private lazy var model: Model = .init(maxNumberOfItemsPerSection: traitCollection.userInterfaceIdiom == .pad ? 8 : 5,
                                          activeButtons: [.hangUp, .microphone])

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationItem()
        setupHierarchy()
        setupConstraints()
        inactiveButtonsCollectionView.dataSource = inactiveButtonsDataSource
        activeButtonsCollectionView.dataSource = activeButtonsDataSource
    }

    private func setupNavigationItem() {
        navigationItem.title = "Custom bottom sheet"
        navigationItem.rightBarButtonItem = editButtonItem
    }

    private func setupHierarchy() {
        view.addSubview(inactiveButtonsCollectionView)
        view.addSubview(activeButtonsCollectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            inactiveButtonsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            inactiveButtonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            inactiveButtonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            inactiveButtonsCollectionView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            activeButtonsCollectionView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            activeButtonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 14),
            activeButtonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -14),
            activeButtonsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            activeButtonsCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 66)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        inactiveButtonsDataSource.apply(model.inactiveButtons.snapshot(), animatingDifferences: animated)
        activeButtonsDataSource.apply(model.activeButtons.snapshot(), animatingDifferences: animated)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        activeButtonsCollectionView.isEditing = editing
    }

    private func deleteCell(_ cell: UICollectionViewCell, from collectionView: UICollectionView) {
        guard collectionView == activeButtonsCollectionView else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        model.deactivateButton(at: indexPath)
        applySnapshots(animatingDifferences: true)
    }

    private func applySnapshots(animatingDifferences animated: Bool) {
        inactiveButtonsDataSource.apply(model.inactiveButtons.snapshot(), animatingDifferences: animated)
        activeButtonsDataSource.apply(model.activeButtons.snapshot(), animatingDifferences: animated)
    }
}

@available(iOS 15.0, *)
private extension BottomSheetViewController {

    private struct Model {

        private(set) var activeButtons: Buttons
        private(set) var inactiveButtons: Buttons

        init(maxNumberOfItemsPerSection: Int, activeButtons: [Button]) {
            self.activeButtons = .init(maxNumberOfItemsPerSection: maxNumberOfItemsPerSection, buttons: activeButtons)
            self.inactiveButtons = .init(maxNumberOfItemsPerSection: .max, buttons: Button.allCases.filter({ !activeButtons.contains($0) }))
        }

        mutating func activateButton(_ button: Button) {
            activeButtons.insert(button)
            inactiveButtons.remove(button)
        }

        mutating func deactivateButton(_ button: Button) {
            inactiveButtons.insert(button)
            activeButtons.remove(button)
        }

        mutating func deactivateButton(at indexPath: IndexPath) {
            let button = activeButtons.button(at: indexPath)
            activeButtons.remove(button)
            inactiveButtons.insert(button)
        }

        mutating func moveActiveButton(_ button: Button, to destinationIndexPath: IndexPath) {
            activeButtons.moveItem(button, to: destinationIndexPath)
        }

        struct Buttons {

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

            private var sections: [Section<Button>] = []

            init(maxNumberOfItemsPerSection: Int, buttons: [Button]) {
                self.maxNumberOfItemsPerSection = maxNumberOfItemsPerSection
                self.buttons = buttons
                updateSections()
            }

            private mutating func updateSections() {
                var sections = [Section<Button>](repeating: .init(items: []), count: numberOfSections)

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

            mutating func moveItem(_ button: Button, to destinationIndexPath: IndexPath) {
                guard let sourceIndexPath = indexPath(for: button) else { return }
                sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
                sections[destinationIndexPath.section].items.insert(button, at: destinationIndexPath.item)
            }

            mutating func insert(_ button: Button) {
                buttons.append(button)
            }

            mutating func remove(_ button: Button) {
                guard let indexPath = indexPath(for: button) else { return }

                deleteItem(at: indexPath)
            }

            mutating func deleteItem(at indexPath: IndexPath) {
                sections[indexPath.section].items.remove(at: indexPath.item)
            }

            func snapshot() -> NSDiffableDataSourceSnapshot<Int, Button> {
                var snapshot = NSDiffableDataSourceSnapshot<Int, Button>()
                snapshot.appendSections(sections.indices.map({ $0 }))

                sections.enumerated().forEach { (index, section) in
                    snapshot.appendItems(section.items, toSection: index)
                }

                return snapshot
            }
        }
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView == activeButtonsCollectionView else { return .init(width: 68, height: 85) }
        guard indexPath.section == model.activeButtons.numberOfSections - 1 else { return .init(width: 68, height: 85) }
        return .init(width: 68, height: 46)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard collectionView == activeButtonsCollectionView else { return .zero }
        let topInset: CGFloat = section == 0 ? 10 : 0
        let bottomInset: CGFloat = section == model.activeButtons.numberOfSections - 1 ? 10 : 0
        return .init(top: topInset, left: 4, bottom: bottomInset, right: 4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard collectionView == activeButtonsCollectionView else { return .zero }
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let button = if collectionView == activeButtonsCollectionView {
            model.activeButtons.button(at: indexPath)
        } else {
            model.inactiveButtons.button(at: indexPath)
        }

        let itemProvider = NSItemProvider(object: button.identifier as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = DragItem(collectionView: collectionView, button: button)
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        true
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        setEditing(true, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard let item = session.items.first?.localObject as? DragItem else { return .init(operation: .cancel) }

        if item.collectionView == activeButtonsCollectionView, collectionView == item.collectionView, destinationIndexPath != nil {
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
                if dragItem.collectionView == activeButtonsCollectionView {
                    model.deactivateButton(dragItem.button)
                    applySnapshots(animatingDifferences: true)

                    guard let indexPath = model.inactiveButtons.indexPath(for: dragItem.button) else { continue }
                    coordinator.drop(item.dragItem, toItemAt: indexPath)
                } else {
                    model.activateButton(dragItem.button)
                    applySnapshots(animatingDifferences: true)

                    guard let indexPath = model.activeButtons.indexPath(for: dragItem.button) else { continue }
                    coordinator.drop(item.dragItem, toItemAt: indexPath)
                }
            } else if coordinator.proposal.operation == .move, let destinationIndexPath = coordinator.destinationIndexPath {
                guard dragItem.collectionView == activeButtonsCollectionView else { continue }

                model.moveActiveButton(dragItem.button, to: destinationIndexPath)
                activeButtonsDataSource.apply(model.activeButtons.snapshot(), animatingDifferences: true)

                guard let indexPath = model.activeButtons.indexPath(for: dragItem.button) else { continue }
                coordinator.drop(item.dragItem, toItemAt: indexPath)
            }
        }
    }

    private struct DragItem {
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

@available(iOS 15.0, *)
private extension UICollectionView {

    convenience init(delegate: UICollectionViewDragDelegate & UICollectionViewDropDelegate & UICollectionViewDelegateFlowLayout) {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.dragDelegate = delegate
        self.dropDelegate = delegate
        self.isScrollEnabled = false
        self.registerReusableCell(ButtonCell.self)
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(rgb: 0xEEEEEE)
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        self.backgroundView = view
    }
}
