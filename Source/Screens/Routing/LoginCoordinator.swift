// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class LoginCoordinator: BaseCoordinator {

    private let config: Config

    private lazy var loginController: LoginViewController = LoginViewController(services: services)

    var controller: UIViewController {
        loginController
    }

    private var presentationAdapter: LoginLoaderPresentationAdapter?
    private var searchController: UISearchController?

    init(config: Config, services: ServicesFactory) {
        self.config = config
        super.init(services: services)
    }

    func start(onDismiss: @escaping (Contact?) -> Void) {
        let searchController = makeSearchController()

        presentationAdapter = LoginLoaderPresentationAdapter(store: services.makeContactsStore(config: config),
                                                             presenter: ContactsPresenter(output: Weak(object: loginController)))

        loginController.navigationItem.searchController = searchController
        loginController.navigationItem.hidesSearchBarWhenScrolling = false
        loginController.definesPresentationContext = true
        loginController.onSelection = onDismiss
        loginController.onReady = presentationAdapter?.fetchUsers
        loginController.handleErrorTapped = { onDismiss(nil) }
    }
}

extension LoginCoordinator: UISearchBarDelegate {

    private func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Strings.Login.searchPlaceholder
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = .default
        return searchController
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presentationAdapter?.filter(searchFilter: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presentationAdapter?.filter(searchFilter: "")
    }
}