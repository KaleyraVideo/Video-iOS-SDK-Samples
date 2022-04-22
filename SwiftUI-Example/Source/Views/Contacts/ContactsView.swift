//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct ContactsView: View {
    
    init(addressBook: AddressBook?) {
        self.addressBook = addressBook
    }

    var addressBook: AddressBook?
    @State private var favoriteColor = 0

    var body: some View {
        NavigationView {
            List(addressBook?.contacts ?? [], id: \.alias.hashValue) { contact in
                ContactRow(contact: contact)
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image("logout")
                    }
                }

                ToolbarItem(placement: .principal) {
                    HStack {
                        Picker("What is your favorite color?", selection: $favoriteColor) {
                            Text("Call").tag(0)
                            Text("Conference").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200, height: nil, alignment: .center)
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button(addressBook?.me?.alias ?? "") {
                            
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Image("settings")
                        }
                    }
                }
            })
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AddressBook.instance.update(withAliases: ["user_1", "user_2", "user_3", "user_4"], currentUser: "user_5")
        return ContactsView(addressBook: AddressBook.instance)
    }
}
