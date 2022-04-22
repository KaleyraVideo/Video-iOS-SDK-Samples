//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import Bandyer

class LoginViewModel: NSObject, ObservableObject {

    @Published private(set) var userIds: [String] = []
    @Published var loggedIn = false
    @Published private(set) var userInteractionEnabled = true

    private (set) var selectedUserId = UserSession.currentUser
    private (set) var addressBook: AddressBook?

    private let repository = RestUserRepository()

    func refreshUsers() {

        //Here we are fetching user information from our backend system.
        //We are doing this in order to have the list of available users we can impersonate.
        repository.fetchAllUsers { [weak self] aliases, error in

            guard let self = self else { return }
            guard error == nil else { return }
            guard let users = aliases else { return }

            self.userIds = users

            self.loginUser()
        }
    }
    
    func select(userID: String) {
        selectedUserId = userID
        loginUser()
    }

    // MARK: - Login

    private func loginUser() {
        guard let selectedUserId = self.selectedUserId else { return }

        //Once the end user has selected which user wants to impersonate, we start the SDK client.
        //We are opening a session with the selected user id by telling the BandyerSDK to open a new session.
        BandyerSDK.instance().openSession(userId: selectedUserId)
        
        //We are registering as a call client observer in order to be notified when the client changes its state.
        //We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
        //otherwise the SDK will notify the observer onto its background internal queue.
        BandyerSDK.instance().callClient.add(observer: self, queue: .main)

        //Then we start the call client for the user selected.
        BandyerSDK.instance().callClient.start()

        //Here we start the chat client for the user selected.
        BandyerSDK.instance().chatClient.start()

        AddressBook.instance.update(withAliases: userIds, currentUser: selectedUserId)

        let addressBook = AddressBook.instance

        //This statement tells the Bandyer SDK which object, conforming to `UserDetailsProvider` protocol
        //should use to present contact information in its views.
        //The backend system does not send any user information to its clients, the SDK and the backend system identify the users in any view
        //using their user aliases, it is your responsibility to match "user aliases" with the corresponding user object in your system
        //and provide those information to the Bandyer SDK.
        BandyerSDK.instance().userDetailsProvider = UserDetailsProvider(addressBook)

        self.addressBook = addressBook
    }
}

extension LoginViewModel: CallClientObserver {

    func callClientWillStart(_ client: CallClient) {
        userInteractionEnabled = false
    }

    func callClientDidStart(_ client: CallClient) {
        UserSession.currentUser = selectedUserId
        loggedIn = true
        userInteractionEnabled = true
    }

    func callClient(_ client: CallClient, didFailWithError error: Error) {
        userInteractionEnabled = true
    }
}
