// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIView {

    func startWobbling() {
        guard layer.animation(forKey: "wobble") == nil else { return }

        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0.0, -0.025, 0.0, 0.025, 0.0]
        animation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        animation.duration = 0.4
        animation.isAdditive = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animation, forKey: "wobble")
    }

    func stopWobbling() {
        guard layer.animation(forKey: "wobble") != nil else { return }

        layer.removeAnimation(forKey: "wobble")
    }
}
