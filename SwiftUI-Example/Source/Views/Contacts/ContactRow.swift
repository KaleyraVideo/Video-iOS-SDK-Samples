//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct ContactRow: View {
    
    var contact: Contact
    var multipleSelection: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(contact.fullName ?? "")
                    .font(.headline)
                Text(contact.alias)
                    .font(.subheadline)
            }
            Spacer()
            Image("phone").isHidden(multipleSelection)
        }
    }
}

struct ContactRow_Previews: PreviewProvider {
    static var previews: some View {
        var contact = Contact("user_123")
        contact.firstName = "John"
        contact.lastName = "Appleseed"
        return ContactRow(contact: contact, multipleSelection: false)
    }
}
