// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import Combine
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class BottomSheetViewController: UIViewController {

    private lazy var addButtonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap a button to add it to the bottom sheet below"
        label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 16))
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var reorderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap a button to remove it. Long press and drag to reorder the buttons"
        label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.systemFont(ofSize: 16))
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var inactiveButtonsCollectionView: IntrinsicContentSizeCollectionView = .init(delegate: self)
    private lazy var activeButtonsCollectionView: IntrinsicContentSizeCollectionView = .init(delegate: self)

    private lazy var inactiveButtonsDataSource: UICollectionViewDiffableDataSource<Int, Button> = {
        .init(collectionView: inactiveButtonsCollectionView) { collectionView, indexPath, button in
            let cell = collectionView.dequeueReusableCell(ButtonCell.self, for: indexPath)
            cell.deleteConfig = .delete
            cell.configure(for: button, shouldShowTitle: true)
            cell.deleteAction = { [weak self] cell in
                self?.deleteCell(cell, from: collectionView)
            }
            return cell
        }
    }()

    private lazy var activeButtonsDataSource: UICollectionViewDiffableDataSource<Int, Button> = {
        var dataSource = UICollectionViewDiffableDataSource<Int, Button>(collectionView: activeButtonsCollectionView) { collectionView, indexPath, button in
            let cell = collectionView.dequeueReusableCell(ButtonCell.self, for: indexPath)
            cell.deleteConfig = .remove
            cell.configure(for: button, shouldShowTitle: indexPath.section != collectionView.numberOfSections - 1)
            cell.deleteAction = { [weak self] cell in
                self?.deleteCell(cell, from: collectionView)
            }
            return cell
        }
        dataSource.reorderingHandlers.canReorderItem = { _ in true }
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            guard let self else { return }

            self.model.updateActiveButtons(from: transaction.finalSnapshot)
        }
        return dataSource
    }()

    private lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
    }()

    private lazy var model: Model = {
        .init(traits: traitCollection, activeButtons: settings.callSettings.buttons ?? [], customButtons: settings.customButtons)
    }()

    private let settings: AppSettings
    private let repository: SettingsRepository
    private lazy var subscriptions = Set<AnyCancellable>()

    var onEditButtonAction: ((Button.Custom) -> Void)?

    init(settings: AppSettings, services: ServicesFactory) {
        self.settings = settings
        self.repository = services.makeSettingsRepository()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupNavigationItem()
        setupHierarchy()
        setupConstraints()
        inactiveButtonsCollectionView.dataSource = inactiveButtonsDataSource
        activeButtonsCollectionView.dataSource = activeButtonsDataSource
        activeButtonsCollectionView.addGestureRecognizer(longPressRecognizer)
        settings.$customButtons.receive(on: RunLoop.main).sink { [weak self] customButtons in
            guard let self else { return }
            self.model.customButtons = customButtons
            self.applySnapshots(animatingDifferences: true)
        }.store(in: &subscriptions)
        setEditing(true, animated: false)
    }

    private func setupNavigationItem() {
        navigationItem.title = "Custom bottom sheet"
        navigationItem.rightBarButtonItem = editButtonItem
    }

    private func setupHierarchy() {
        view.addSubview(addButtonLabel)
        view.addSubview(inactiveButtonsCollectionView)
        view.addSubview(reorderLabel)
        view.addSubview(activeButtonsCollectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addButtonLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            addButtonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inactiveButtonsCollectionView.topAnchor.constraint(equalTo: addButtonLabel.bottomAnchor, constant: 20),
            inactiveButtonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            inactiveButtonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            inactiveButtonsCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: activeButtonsCollectionView.topAnchor, constant: -8),
            inactiveButtonsCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 66),
            reorderLabel.bottomAnchor.constraint(equalTo: activeButtonsCollectionView.topAnchor, constant: -16),
            reorderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reorderLabel.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            reorderLabel.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            activeButtonsCollectionView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            activeButtonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            activeButtonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
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
        inactiveButtonsCollectionView.isEditing = editing
        model.isEditing = editing
        applySnapshots(animatingDifferences: animated)
    }

    private func deleteCell(_ cell: UICollectionViewCell, from collectionView: UICollectionView) {
        if collectionView == activeButtonsCollectionView {
            guard let indexPath = collectionView.indexPath(for: cell) else { return }

            model.deactivateButton(at: indexPath)
        } else {
            guard let indexPath = collectionView.indexPath(for: cell) else { return }

            let button = model.inactiveButtons.button(at: indexPath)
            guard case Button.custom(let customButton) = button else { return }

            settings.customButtons.removeAll(where: { customButton.identifier == $0.identifier })
            try? repository.store(settings.customButtons)
        }

        applySnapshots(animatingDifferences: true)
    }

    private func applySnapshots(animatingDifferences animated: Bool) {
        inactiveButtonsDataSource.apply(model.inactiveButtons.snapshot(), animatingDifferences: animated)
        activeButtonsDataSource.apply(model.activeButtons.snapshot(), animatingDifferences: animated)
    }

    @objc
    private func onLongPress(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
            case .began:
                guard let indexPath = activeButtonsCollectionView.indexPathForItem(at: recognizer.location(in: activeButtonsCollectionView)) else { return }
                activeButtonsCollectionView.beginInteractiveMovementForItem(at: indexPath)
            case .changed:
                activeButtonsCollectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: activeButtonsCollectionView))
            case .ended:
                activeButtonsCollectionView.endInteractiveMovement()
            default:
                activeButtonsCollectionView.cancelInteractiveMovement()
        }
    }
}

@available(iOS 15.0, *)
private extension BottomSheetViewController {

    private struct Model {

        private(set) var activeButtons: Buttons
        private(set) var inactiveButtons: Buttons

        private let maxItemsPerSection: Int

        var isEditing: Bool = false {
            didSet {
                update()
            }
        }

        var customButtons: [Button.Custom] {
            didSet {
                update()
            }
        }

        init(traits: UITraitCollection, activeButtons: [Button], customButtons: [Button.Custom]) {
            self.customButtons = customButtons
            self.maxItemsPerSection = traits.userInterfaceIdiom == .pad ? 8 : 5
            self.activeButtons = .init(maxNumberOfItemsPerSection: traits.userInterfaceIdiom == .pad ? 8 : 5, buttons: activeButtons)
            self.inactiveButtons = .init(maxNumberOfItemsPerSection: .max, buttons: (Button.allCases + customButtons.map({ .custom($0) })).filter({ !activeButtons.contains($0) }))
        }

        mutating func update() {
            let currentActiveButtons = activeButtons.buttons
            var inactiveButtons = (Button.allCases + customButtons.map({ .custom($0) })).filter({ !currentActiveButtons.contains($0) })
            if isEditing {
                inactiveButtons.append(.addCustom)
            }
            self.activeButtons = .init(maxNumberOfItemsPerSection: maxItemsPerSection, buttons: currentActiveButtons)
            self.inactiveButtons = .init(maxNumberOfItemsPerSection: .max, buttons: inactiveButtons)
        }

        mutating func activateButton(_ button: Button) {
            activeButtons.insert(button)
            inactiveButtons.remove(button)
        }

        mutating func activateButton(at indexPath: IndexPath) {
            activateButton(inactiveButtons.button(at: indexPath))
        }

        mutating func deactivateButton(_ button: Button) {
            inactiveButtons.insert(button)
            activeButtons.remove(button)
        }

        mutating func deactivateButton(at indexPath: IndexPath) {
            deactivateButton(activeButtons.button(at: indexPath))
        }

        mutating func moveActiveButton(_ button: Button, to destinationIndexPath: IndexPath) {
            activeButtons.moveItem(button, to: destinationIndexPath)
        }

        mutating func updateActiveButtons(from snapshot: NSDiffableDataSourceSnapshot<Int, Button>) {
            activeButtons.update(from: snapshot)
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
                buttons.removeAll(where: { $0 == button })
            }

            func snapshot() -> NSDiffableDataSourceSnapshot<Int, Button> {
                var snapshot = NSDiffableDataSourceSnapshot<Int, Button>()
                snapshot.appendSections(sections.indices.map({ $0 }))

                sections.enumerated().forEach { (index, section) in
                    snapshot.appendItems(section.items, toSection: index)
                }

                return snapshot
            }

            mutating func update(from snapshot: NSDiffableDataSourceSnapshot<Int, Button>) {
                buttons = snapshot.itemIdentifiers
            }
        }
    }
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        guard collectionView == inactiveButtonsCollectionView else { return true }
        let item = model.inactiveButtons.button(at: indexPath)
        guard case Button.custom = item else { return false }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == inactiveButtonsCollectionView {
            let selectedButton = model.inactiveButtons.button(at: indexPath)

            switch selectedButton {
                case .addCustom:
                    onEditButtonAction?(.new)
                case .custom(let custom) where !isEditing:
                    onEditButtonAction?(custom)
                default:
                    model.activateButton(selectedButton)
                    applySnapshots(animatingDifferences: true)
            }
        } else {
            model.deactivateButton(model.activeButtons.button(at: indexPath))
            applySnapshots(animatingDifferences: true)
        }
    }

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

    convenience init(delegate: UICollectionViewDelegateFlowLayout) {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.isScrollEnabled = false
        self.allowsSelectionDuringEditing = true
        self.registerReusableCell(ButtonCell.self)
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(rgb: 0xEEEEEE)
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        self.backgroundView = view
    }
}
