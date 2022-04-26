//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI

struct ContactsView: View {

    @ObservedObject private var viewModel: ContactsViewModel

    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List(viewModel.contacts, id: \.self, selection: $viewModel.selectedContacts) { contact in
                ContactRow(contact: contact, multipleSelection: viewModel.multipleSelectionEnabled)
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
                        Picker("What is your favorite color?", selection: $viewModel.desiredCallType.animation(.linear)) {
                            Text("Call").tag(ContactsViewModel.CallType.call)
                            Text("Conference").tag(ContactsViewModel.CallType.conference)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200, height: nil, alignment: .center)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.callSelectedUsers()
                    }, label: {
                        Image("phone")
                    })
                    .disabled(!viewModel.canCallManyToMany)
                    .isHidden(!viewModel.multipleSelectionEnabled)
                }

                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button(viewModel.loggedUserAlias) {
                            
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
            .environment(\.editMode, Binding(get: {
                viewModel.multipleSelectionEnabled ? EditMode.active : EditMode.inactive
            }, set: { newVal in
                viewModel.multipleSelectionEnabled = newVal.isEditing
            }))
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AddressBook.instance.update(withAliases: ["user_1", "user_2", "user_3", "user_4"], currentUser: "user_5")
        let viewModel = ContactsViewModel(addressBook: AddressBook.instance)
        return ContactsView(viewModel: viewModel)
    }
}
