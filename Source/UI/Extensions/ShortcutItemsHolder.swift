// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

protocol ShortcutItemsHolder: AnyObject {

    var shortcutItems: [UIApplicationShortcutItem]? { get set }
}

extension UIApplication: ShortcutItemsHolder {}
