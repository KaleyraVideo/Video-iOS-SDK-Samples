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

    private lazy var buttons: [Button] = [.hangUp, .microphone, .camera, .flipCamera, .cameraEffects, .audioOutput, .fileShare, .screenShare, .chat, .whiteboard]

    private var maxNumberOfItemsPerSection: Int {
        traitCollection.userInterfaceIdiom == .pad ? 8 : 5
    }

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
            buttonsCollectionView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            buttonsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 14),
            buttonsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -14),
            buttonsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
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
        guard !buttons.isEmpty else { return 0 }

        let (quotient, reminder) = buttons.count.quotientAndRemainder(dividingBy: maxNumberOfItemsPerSection)
        guard reminder != 0 else { return quotient }
        return quotient + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        maxNumberOfItemsPerSection
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemIndex = indexPath.section * maxNumberOfItemsPerSection + indexPath.item
        guard itemIndex < buttons.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "placeholder", for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ButtonCell.self)", for: indexPath) as! ButtonCell
        let section = indexPath.section * maxNumberOfItemsPerSection
        cell.configure(for: buttons.reversed()[section + (maxNumberOfItemsPerSection * (section + 1) - (indexPath.item + 1)) % maxNumberOfItemsPerSection])
        cell.configurationUpdateHandler = { cell, state in
            if state.isEditing {
                cell.startWobbling()
            } else {
                cell.stopWobbling()
            }
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
