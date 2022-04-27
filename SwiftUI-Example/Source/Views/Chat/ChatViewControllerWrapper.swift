//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer
import SwiftUI

struct ChatViewControllerWrapper: UIViewControllerRepresentable {

    private var channelViewController = ChannelViewController()

    private var strongDelegate: ChannelViewControllerDelegate?
    var delegate: ChannelViewControllerDelegate? {
        get {
            channelViewController.delegate
        }
        set {
            strongDelegate = newValue
            channelViewController.delegate = newValue
        }
    }

    var intent: OpenChatIntent? {
        get {
            channelViewController.intent
        }
        set {
            channelViewController.intent = newValue
        }
    }

    func makeUIViewController(context: Context) -> ChannelViewController {
        channelViewController
    }

    func updateUIViewController(_ uiViewController: ChannelViewController, context: Context) { }
}
