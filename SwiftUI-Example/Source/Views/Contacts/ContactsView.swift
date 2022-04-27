//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI
import Combine

struct ContactsView: View {

    @ObservedObject private var viewModel: ContactsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List(viewModel.contacts, id: \.self, selection: $viewModel.selectedContacts) { contact in
                Button {
                    viewModel.call(user: contact)
                } label: {
                    ContactRow(contact: contact, multipleSelection: viewModel.multipleSelectionEnabled) {
                        viewModel.openChat(with: contact)
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.logout()
                        dismiss()
                    } label: {
                        Image("logout")
                            .renderingMode(.template)
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
                            .renderingMode(.template)
                    })
                    .disabled(!viewModel.canCallManyToMany)
                    .isHidden(!viewModel.multipleSelectionEnabled)
                }

                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text(viewModel.loggedUserAlias)
                            .foregroundColor(.accentColor)
                            .padding(.leading, 34)
                        Spacer()
                        NavigationLink {
                            CallOptionsView(options: viewModel.options)
                        } label: {
                            Image("settings")
                                .renderingMode(.template)
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
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text(viewModel.alertToPresent!.title), message: Text(viewModel.alertToPresent!.message), dismissButton: .default(Text("Ok")))
            }
            .sheet(isPresented: $viewModel.showingChat) {
                viewModel.chatViewToPresent!
            }
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
