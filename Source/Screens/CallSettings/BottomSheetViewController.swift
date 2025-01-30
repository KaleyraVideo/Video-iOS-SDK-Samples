// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
import KaleyraVideoSDK

@available(iOS 15.0, *)
final class BottomSheetViewController: UIViewController {

    private lazy var buttonsCollectionView: UICollectionView = {
        let collection = IntrinsicContentSizeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
        collection.register(ButtonCell.self, forCellWithReuseIdentifier: "\(ButtonCell.self)")
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "placeholder")
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

        private(set) var buttons: [Button] = [.hangUp, .microphone, .camera, .flipCamera, .cameraEffects, .audioOutput, .fileShare, .screenShare, .chat, .whiteboard] {
            didSet {
                updateSections()
            }
        }

        var numberOfSections: Int {
            let (quotient, reminder) = buttons.count.quotientAndRemainder(dividingBy: maxNumberOfItemsPerSection)
            return reminder != 0 ? quotient + 1 : quotient
        }

        private var sections: [Section] = []

        init(maxNumberOfItemsPerSection: Int) {
            self.maxNumberOfItemsPerSection = maxNumberOfItemsPerSection
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

    private lazy var model: ViewModel = .init(maxNumberOfItemsPerSection: traitCollection.userInterfaceIdiom == .pad ? 8 : 5)

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Custom bottom sheet"
        navigationItem.rightBarButtonItem = editButtonItem
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        view.addSubview(containerView)
        view.addSubview(buttonsCollectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
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

    private func deleteButton(at indexPath: IndexPath) {
        model.deleteItem(at: indexPath)

        buttonsCollectionView.performBatchUpdates {
            buttonsCollectionView.deleteItems(at: [indexPath])
        }
    }
}

@available(iOS 15.0, *)
internal enum Button {
    case hangUp
    case microphone
    case camera
    case flipCamera
    case cameraEffects
    case audioOutput
    case fileShare
    case screenShare
    case chat
    case whiteboard

    var title: String {
        switch self {
            case .hangUp:
                "end"
            case .microphone:
                "mute"
            case .camera:
                "enable"
            case .flipCamera:
                "flip"
            case .cameraEffects:
                "effects"
            case .audioOutput:
                "audio output"
            case .fileShare:
                "fileshare"
            case .screenShare:
                "screenshare"
            case .chat:
                "chat"
            case .whiteboard:
                "board"
        }
    }

    var icon: UIImage? {
        let icon: UIImage? = switch self {
            case .hangUp:
                .init(named: "end-call", in: .kaleyraVideo, compatibleWith: nil)
            case .microphone:
                .init(named: "mic-off", in: .kaleyraVideo, compatibleWith: nil)
            case .camera:
                .init(named: "camera-off", in: .kaleyraVideo, compatibleWith: nil)
            case .flipCamera:
                .init(named: "flipcam", in: .kaleyraVideo, compatibleWith: nil)
            case .cameraEffects:
                .init(named: "virtual-background", in: .kaleyraVideo, compatibleWith: nil)
            case .audioOutput:
                .init(named: "speaker-on", in: .kaleyraVideo, compatibleWith: nil)
            case .fileShare:
                .init(named: "file-share", in: .kaleyraVideo, compatibleWith: nil)
            case .screenShare:
                .init(named: "screen-share", in: .kaleyraVideo, compatibleWith: nil)
            case .chat:
                .init(named: "chat", in: .kaleyraVideo, compatibleWith: nil)
            case .whiteboard:
                .init(named: "whiteboard", in: .kaleyraVideo, compatibleWith: nil)
        }
        return icon ?? .init(systemName: "questionmark")
    }

    var backgroundColor: UIColor {
        guard case Button.hangUp = self else {
            return .init(rgb: 0xE2E2E2)
        }
        return .init(rgb: 0xDC2138)
    }

    var tintColor: UIColor {
        guard case Button.hangUp = self else {
            return .init(rgb: 0x1B1B1B)
        }
        return .white
    }
}

@available(iOS 15.0, *)
private extension Bundle {

    static let kaleyraVideo: Bundle = .init(for: KaleyraVideo.self)
}

@available(iOS 15.0, *)
extension BottomSheetViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        model.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ButtonCell.self)", for: indexPath) as! ButtonCell
        cell.configure(for: model.button(at: indexPath))
        cell.deleteAction = { [weak self] cell in
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            self?.deleteButton(at: indexPath)
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
        .init(top: 10, left: 4, bottom: 0, right: 4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4
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
