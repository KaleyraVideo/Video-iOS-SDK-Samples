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
                UserRow(userID: userId).onTapGesture {
                    viewModel.select(userID: userId)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProgressView().isHidden(!viewModel.userInteractionEnabled)
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
            ContactsView(addressBook: viewModel.addressBook)
        })
        .allowsHitTesting(viewModel.userInteractionEnabled)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
