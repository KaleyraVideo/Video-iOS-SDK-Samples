//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct ContactRow: View {
    
    var contact: Contact
    var multipleSelection: Bool
    var chatAction: (() -> Void)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(contact.fullName ?? "")
                    .font(.headline)
                Text(contact.alias)
                    .font(.subheadline)
            }

            Spacer()

            Button {
                chatAction()
            } label: {
                Image("chat")
                    .renderingMode(.template)
            }
            .isHidden(multipleSelection)
            .padding(.trailing, 10)

            Image("phone")
                .renderingMode(.template)
                .foregroundColor(.accentColor)
                .isHidden(multipleSelection)
        }
    }
}

struct ContactRow_Previews: PreviewProvider {
    static var previews: some View {
        var contact = Contact("user_123")
        contact.firstName = "John"
        contact.lastName = "Appleseed"
        return ContactRow(contact: contact, multipleSelection: false) { }
    }
}
