//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI
import Bandyer

struct RecordRow: View {

    var recordingType: Bandyer.CallRecordingType
    @ObservedObject var options: CallOptionsItem
    @SwiftUI.Environment(\.colorScheme) var colorScheme: SwiftUI.ColorScheme

    var body: some View {
        Button {
            options.recordingType = recordingType
        } label: {
            HStack {
                Text(recordingType.description)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundColor(.accentColor)
                    .isHidden(recordingType != options.recordingType)
            }
        }
        .buttonStyle(.automatic)
    }
}

struct RecordRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordRow(recordingType: .manual, options: CallOptionsItem())
    }
}

extension Bandyer.CallRecordingType: CustomStringConvertible {
    public var description: String {
        switch self {
            case .none:
                return "None"
            case .manual:
                return "Manual"
            case .automatic:
                return "Automatic"
        }
    }
}
