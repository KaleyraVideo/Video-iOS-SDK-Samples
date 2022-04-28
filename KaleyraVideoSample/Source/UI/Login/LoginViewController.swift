//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit
import Bandyer

class LoginViewController: UITableViewController {

    // This view controller acts as the root view controller of your app.
    // In order for the SDK to receive or make calls we must start it specifying which user is connecting to Bandyer platform.
    // Bandyer SDK uses an "user ID" to identify a user, you can think of it as an alphanumeric unique "slug" which identifies
    // a user in your company. The SDK needs this "user ID" to connect, so you must retrieve it in some way from your back-end system.
    // Let's pretend this is the login screen of your app where the user enters hers/his credentials.
    // Once your app has been able to authenticate her/him, hers/his "user ID" should be available to you and it should be ready
    // to be used to start the Bandyer SDK.
    // In this sample app, we simulate those steps retrieving from our backend system all the users belonging to a company of our own.
    // Then when the end user selects the user she/he wants to sign-in as, we start the SDK client and if everything went fine we let her/him
    // proceed to the next screen.

    private let cellIdentifier = "userCellId"
    private let segueIdentifier = "showContactsSegue"

    private (set) var selectedUserId = UserSession.currentUser
    private (set) var repository = RestUserRepository()
    private (set) var userIds: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var addressBook: AddressBook?

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(self, action: #selector(refreshControlDidRefresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshUsers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cleanUp()
    }

    private func cleanUp() {
        selectedUserId = nil
        addressBook = nil
    }

    // MARK: - Refreshing users list

    func refreshUsers() {
        refreshControl?.beginRefreshing()

        //Here we are fetching user information from our backend system.
        //We are doing this in order to have the list of available users we can impersonate.
        repository.fetchAllUsers { [weak self] fetchedUserIDs, error in
            guard let self = self else { return }

            self.refreshControl?.endRefreshing()

            guard error == nil else {
                return
            }

            guard let users = fetchedUserIDs else {
                return
            }

            self.userIds = users

            self.loginUser()
        }
    }

    @objc
    func refreshControlDidRefresh(_ sender: UIRefreshControl) {
        refreshUsers()
    }

    // MARK: - Login

    func loginUser() {
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

    // MARK: - Navigating to contacts

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier else { return }
        guard let navController = segue.destination as? UINavigationController else { return }
        guard let controller = navController.topViewController as? ContactsViewController else { return }

        controller.addressBook = addressBook
    }
}

extension LoginViewController: CallClientObserver {

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

    private func callClientWillStart() {
        view.isUserInteractionEnabled = false

        showActivityIndicatorInNavigationBar()
    }

    private func callClientDidStart() {
        guard presentedViewController == nil else { return }

        UserSession.currentUser = selectedUserId

        performSegue(withIdentifier: segueIdentifier, sender: self)
        hideActivityIndicatorFromNavigationBar()
        view.isUserInteractionEnabled = true

        // After the call client has started we can also start our custom callDetector, if we decided to turn off the automatic management of the VoIP push notifications by the sdk.
        (UIApplication.shared.delegate as? AppDelegate)?.startCallDetectorIfNeeded()
    }

    func callClient(_ client: CallClient, didFailWithError error: Error) {
        hideActivityIndicatorFromNavigationBar()
        view.isUserInteractionEnabled = true
    }
}

// MARK: - Activity indicator

extension LoginViewController {

    func showActivityIndicatorInNavigationBar() {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let indicator = UIActivityIndicatorView(style: style)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        navigationItem.setRightBarButton(item, animated: true)
    }

    func hideActivityIndicatorFromNavigationBar() {
        navigationItem.setRightBarButton(nil, animated: true)
    }
}

// MARK: - Table view data source

extension LoginViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.text = userIds[indexPath.row]
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = userIds[indexPath.row]
        }
        return cell
    }
}

// MARK: - Table view delegate

extension LoginViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUserId = userIds[indexPath.row]
        loginUser()
    }
}
