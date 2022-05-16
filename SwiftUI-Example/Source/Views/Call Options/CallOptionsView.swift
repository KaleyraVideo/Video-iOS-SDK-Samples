//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct CallOptionsView: View {

    @ObservedObject private var options: CallOptionsItem

    init(options: CallOptionsItem) {
        self.options = options
    }

    var body: some View {
        List {
            Section("Call Type") {
                CallTypeRow(callType: .audioVideo, options: options)
                CallTypeRow(callType: .audioUpgradable, options: options)
                CallTypeRow(callType: .audioOnly, options: options)
            }

            Section("Recording") {
                RecordRow(recordingType: .none, options: options)
                RecordRow(recordingType: .automatic, options: options)
                RecordRow(recordingType: .manual, options: options)
            }

            Section("Other Settings") {
                DurationRow(options: options)
            }
        }
        .navigationTitle(Text("Select Options"))
    }
}

struct CallOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        CallOptionsView(options: CallOptionsItem())
    }
}
