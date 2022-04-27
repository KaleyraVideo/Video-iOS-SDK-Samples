//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import SwiftUI
import Bandyer

struct LoginView: View {

    @ObservedObject private var viewModel: LoginViewModel

    init() {
        self.init(viewModel: LoginViewModel())
    }

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List(viewModel.userIds, id: \.hashValue) { userId in
                Button {
                    viewModel.select(userID: userId)
                } label: {
                    UserRow(userID: userId)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProgressView().isHidden(!viewModel.isLoading)
                }
            })
            .refreshable {
                viewModel.refreshUsers()
            }
            .listStyle(.plain)
            .navigationTitle("Choose a user")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.refreshUsers()
        }
        .fullScreenCover(isPresented: $viewModel.loggedIn, content: {
            getContactsView()
        })
        .allowsHitTesting(viewModel.userInteractionEnabled)
    }

    private func getContactsView() -> AnyView {
        let contactsViewModel = ContactsViewModel(addressBook: viewModel.addressBook)
        let contactView = ContactsView(viewModel: contactsViewModel)
        return AnyView(contactView)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
