//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI
import KaleyraVideoSDK

struct CallTypeRow: View {

    var callType: Bandyer.CallType
    @ObservedObject var options: CallOptionsItem
    @SwiftUI.Environment(\.colorScheme) var colorScheme: SwiftUI.ColorScheme

    var body: some View {
        Button {
            options.type = callType
        } label: {
            HStack {
                Text(callType.description)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundColor(.accentColor)
                    .isHidden(callType != options.type)
            }
        }
        .buttonStyle(.automatic)
    }
}

struct CallTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        CallTypeRow(callType: .audioVideo, options: CallOptionsItem())
    }
}

extension Bandyer.CallType: CustomStringConvertible {
    public var description: String {
        switch self {
            case .audioVideo:
                return "Audio Video"
            case .audioUpgradable:
                return "Audio Upgradable"
            case .audioOnly:
                return "Audio Only"
        }
    }
}
