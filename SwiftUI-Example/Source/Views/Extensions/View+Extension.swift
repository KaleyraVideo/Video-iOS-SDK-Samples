//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
