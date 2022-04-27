//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct RecordRow: View {

    @ObservedObject var options: CallOptionsItem

    var body: some View {
        Toggle("Recording", isOn: $options.record)
    }
}

struct RecordRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordRow(options: CallOptionsItem())
    }
}
