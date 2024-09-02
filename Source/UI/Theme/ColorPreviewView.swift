// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class ColorPreviewView : UIView {

    var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }

            return UIColor(cgColor: cgColor)
        }

        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }

        set {
            layer.borderWidth = newValue
        }
    }

    private var backgroundImageView: UIImageView = {
        let image = UIImageView(image: Icons.redLine)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    func setUpColor(_ color: UIColor?) {
        if color == nil{
            addColorNotSelectedImage()
        } else {
            removeColorNotSelectedImage()
            backgroundColor = color
        }
    }

    func addColorNotSelectedImage() {
        addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }

    func removeColorNotSelectedImage() {
        backgroundImageView.removeFromSuperview()
    }
}
