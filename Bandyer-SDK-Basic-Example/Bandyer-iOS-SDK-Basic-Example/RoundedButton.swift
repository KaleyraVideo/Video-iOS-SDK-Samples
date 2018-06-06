// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit

@IBDesignable class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = CGFloat.minimum(self.bounds.size.width, self.bounds.size.height) * 0.5
    }
    
}
