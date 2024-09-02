//
// Copyright © 2019-Present. Kaleyra S.p.a. All Rights Reserved.
//

import Foundation
import KaleyraVideoSDK

class LoginViewModel: NSObject, ObservableObject {

    @Published private(set) var userIds: [String] = []
    @Published var loggedIn = false
    @Published private(set) var userInteractionEnabled = true
    @Published private(set) var isLoading = false

    private (set) var selectedUserId = UserSession.currentUser
    private (set) var addressBook: AddressBook?

    private let repository = RestUserRepository()

    func refreshUsers() {

        //Here we are fetching user information from our backend system.
        //We are doing this in order to have the list of available users we can impersonate.
        repository.fetchAllUsers { [weak self] fetchedUserIDs, error in

            guard let self = self else { return }
            guard error == nil else { return }
            guard let users = fetchedUserIDs else { return }

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

        // Once the end user has selected which user wants to impersonate, we create a Session object for that user.
        let session = SessionFactory.makeSession(for: selectedUserId)

        // Here we connect the BandyerSDK with the created Session object
        BandyerSDK.instance.connect(session)

        // We are registering as a call client observer in order to be notified when the client changes its state.
        // We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
        // otherwise the SDK will notify the observer onto its background internal queue.
        BandyerSDK.instance.callClient.add(observer: self, queue: .main)

        AddressBook.instance.update(withUserIDs: userIds, currentUser: selectedUserId)

        let addressBook = AddressBook.instance

        // This statement tells the Bandyer SDK which object, conforming to `UserDetailsProvider` protocol
        // should use to present contact information in its views.
        // The backend system does not send any user information to its clients, the SDK and the backend system identify the users in any view
        // using their user IDs, it is your responsibility to match "user IDs" with the corresponding user object in your system
        // and provide those information to the Bandyer SDK.
        BandyerSDK.instance.userDetailsProvider = UserDetailsProvider(addressBook)

        self.addressBook = addressBook
    }
}

extension LoginViewModel: CallClientObserver {

    func callClientDidChangeState(_ client: CallClient, oldState: CallClientState, newState: CallClientState) {
        if newState == .running {
            callClientDidStart()
        }
    }

    func callClientWillChangeState(_ client: CallClient, oldState: CallClientState, newState: CallClientState) {
        if newState == .starting {
            callClientWillStart()
        }
    }

    func callClient(_ client: CallClient, didFailWithError error: Error) {
        userInteractionEnabled = true
        isLoading = false
    }

    private func callClientWillStart() {
        userInteractionEnabled = false
        isLoading = true
    }

    private func callClientDidStart() {
        UserSession.currentUser = selectedUserId
        loggedIn = true
        userInteractionEnabled = true
        isLoading = false

        // After the call client has started we can also start our custom callDetector, if we decided to turn off the automatic management of the VoIP push notifications by the sdk.
        SwiftUI_ExampleApp.appDelegate.startCallDetectorIfNeeded()
    }
}
