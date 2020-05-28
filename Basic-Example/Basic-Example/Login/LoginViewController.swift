//
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import UIKit
import Bandyer

class LoginViewController: UITableViewController {

    //This view controller acts as the root view controller of your app.
    //In order for the SDK to receive or make calls we must start it specifying which user is connecting to Bandyer platform.
    //Bandyer SDK uses an "user alias" to identify a user, you can think of it as an alphanumeric unique "slug" which identifies
    //a user in your company. The SDK needs this "user alias" to connect, so you must retrieve it in some way from your back-end system.
    //Let's pretend this is the login screen of your app where the user enters hers/his credentials.
    //Once your app has been able to authenticate her/him, hers/his "user alias" should be available to you and it should be ready
    //to be used to start the Bandyer SDK.
    //In this sample app, we simulate those steps retrieving from our backend system all the users belonging to a company of our own.
    //Then when the end user selects the user she/he wants to sign-in as, we start the SDK client and if everything went fine we let her/him
    //proceed to the next screen.

    private let cellIdentifier = "userCellId"
    private let segueIdentifier = "showContactsSegue"

    private (set) var selectedUserId = UserSession.currentUser
    private (set) var repository = UserRepository()
    private (set) var userIds: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    //MARK: View

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

        selectedUserId = nil
    }

    //MARK: Refreshing users

    private func refreshUsers() {
        refreshControl?.beginRefreshing()

        repository.fetchAllUsers { [weak self] aliases, error in
            guard let self = self else { return }

            self.refreshControl?.endRefreshing()

            guard error == nil else {
                return
            }

            guard let users = aliases else {
                return
            }

            self.userIds = users

            self.loginUsers()
        }
    }

    @objc func refreshControlDidRefresh(_ sender: UIRefreshControl) {
        refreshUsers()
    }

    //MARK: Login

    private func loginUsers() {
        guard let selectedUserId = self.selectedUserId else {
            return
        }

        //We are registering as a call client observer in order to be notified when the client changes its state.
        //We are also providing the main queue telling the SDK onto which queue should notify the observer provided,
        //otherwise the SDK will notify the observer onto its background internal queue.
        BandyerSDK.instance().callClient.add(observer: self, queue: .main)
        //Then we start the call client providing the "user alias" of the user selected.
        BandyerSDK.instance().callClient.start(selectedUserId)
    }

    //MARK: Navigating to contacts

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier else {
            return
        }
        guard let navController = segue.destination as? UINavigationController else {
            return
        }
        guard let controller = navController.topViewController as? ContactsViewController else {
            return
        }
        guard let selectedUserId = self.selectedUserId else {
            return
        }

        controller.addressBook = AddressBook(userIds, currentUser: selectedUserId)
    }
}

extension LoginViewController: BCXCallClientObserver {
    public func callClientWillStart(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = false

        showActivityIndicatorInNavigationBar()
    }

    public func callClientDidStart(_ client: BCXCallClient) {
        guard presentedViewController == nil else {
            return
        }

        UserSession.currentUser = selectedUserId

        performSegue(withIdentifier: segueIdentifier, sender: self)
        hideActivityIndicatorFromNavigationBar()
        view.isUserInteractionEnabled = true
    }

    public func callClient(_ client: BCXCallClient, didFailWithError error: Error) {
        hideActivityIndicatorFromNavigationBar()
        view.isUserInteractionEnabled = true
    }
}

//MARK: Activity indicator
extension LoginViewController {

    private func showActivityIndicatorInNavigationBar() {
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

    private func hideActivityIndicatorFromNavigationBar() {
        navigationItem.setRightBarButton(nil, animated: true)
    }
}

//MARK: Table view data source
extension LoginViewController {

    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userIds.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = userIds[indexPath.row]
        return cell
    }
}

//MARK: Table view delegate
extension LoginViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUserId = userIds[indexPath.row]
        loginUsers()
    }
}
