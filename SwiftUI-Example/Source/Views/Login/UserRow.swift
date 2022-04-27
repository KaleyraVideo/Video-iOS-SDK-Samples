//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct UserRow: View {
    
    var userID: String
    
    var body: some View {
        Text(userID)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
    }
}

struct UserRow_Previews: PreviewProvider {
    static var previews: some View {
        UserRow(userID: "usr_12345")
    }
}
