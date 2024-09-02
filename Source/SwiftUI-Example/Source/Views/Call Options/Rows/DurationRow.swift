//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct DurationRow: View {

    @ObservedObject var options: CallOptionsItem

    init(options: CallOptionsItem) {
        self.options = options
    }

    var body: some View {
        HStack {
            Text("Maximum duration")
            Spacer()
            TextField("", value: $options.maximumDuration, formatter: NumberFormatter())
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
        }
    }
}

struct DurationRow_Previews: PreviewProvider {
    static var previews: some View {
        DurationRow(options: CallOptionsItem())
    }
}
