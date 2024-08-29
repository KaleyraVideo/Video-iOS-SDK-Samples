//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit
import Combine
import Foundation
import KaleyraVideoSDK

class ContactsViewController: UIViewController {

    //MARK: Constants
    private let cellIdentifier = "userCellId"
    private let optionsSegueIdentifier = "showOptionsSegue"

    //MARK: Outlets and subviews

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var callTypeControl: UISegmentedControl!
    @IBOutlet private var callOptionsBarButtonItem: UIBarButtonItem!
    @IBOutlet private var logoutBarButtonItem: UIBarButtonItem!
    @IBOutlet private var userBarButtonItem: UIBarButtonItem!
    private var callBarButtonItem: UIBarButtonItem?
    private var activityBarButtonItem: UIBarButtonItem?
    private var toastView: UIView?

    var addressBook: AddressBook?

    private var selectedContacts: [IndexPath] = []
    private var options: CallOptionsItem = CallOptionsItem()
    private lazy var subscriptions = Set<AnyCancellable>()

    private lazy var window: CallWindow = {
        guard let scene = view.window?.windowScene else { fatalError() }
        return CallWindow(windowScene: scene)
    }()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        userBarButtonItem.title = UserSession.currentUser
        disableMultipleSelection(false)

        // When view loads we register as a client observer, in order to receive notifications about received incoming calls and client state changes.
        KaleyraVideo.instance.conference?.statePublisher.receive(on: RunLoop.main).sink(receiveValue: { [weak self] state in
            self?.callClientDidChangeState(state)
        }).store(in: &subscriptions)
        KaleyraVideo.instance.conference?.registry.callAddedPublisher.receive(on: RunLoop.main).sink(receiveValue: { [weak self] call in
            self?.presentCall(call)
        }).store(in: &subscriptions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNotificationsCoordinator()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        disableNotificationsCoordinator()
    }

    // MARK: - In-app Notifications

    private func setupNotificationsCoordinator() {
        KaleyraVideo.instance.conversation?.notificationsCoordinator.chatListener = self
        KaleyraVideo.instance.conversation?.notificationsCoordinator.start()
    }

    private func disableNotificationsCoordinator() {
        KaleyraVideo.instance.conversation?.notificationsCoordinator.stop()
    }

    // MARK: - Starting or receiving a call

    private func startOutgoingCall() {
        // To start an outgoing call we must create a `StartOutgoingCallIntent` object specifying who we want to call,
        // the type of call we want to be performed, along with any call option.

        // Here we create the array containing the "user IDs" we want to contact.
        let userIDs = selectedContacts.compactMap { (contactIndex) -> String? in
            addressBook?.contacts[contactIndex.row].userID
        }
        startOutgoingCall(callees: userIDs, options: .init(type: options.type,
                                                           recording: options.recordingType,
                                                           duration: options.maximumDuration))
    }

    private func startOutgoingCall(callees: [String], options: CallOptions) {
        KaleyraVideo.instance.conference?.call(callees: callees, options: options) { _ in }
    }

    // MARK: - Enable / Disable multiple selection

    private func enableMultipleSelection(_ animated: Bool) {
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: animated)
    }

    private func disableMultipleSelection(_ animated: Bool) {
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.setEditing(false, animated: animated)
    }

    // MARK: - Enabling / Disabling chat-phone button

    private func enableChatAndPhoneButtonsOnVisibleCells() {
        let cells = tableView.visibleCells as? [ContactTableViewCell]

        cells?.forEach { cell in
            UIView.animate(withDuration: 0.3, animations: {
                cell.chatButton.alpha = 1
                cell.phoneImg.alpha = 1
            }, completion: { _ in
                cell.chatButton.isEnabled = true
            })
        }
    }
    
    private func disableChatAndPhoneButtonsOnVisibleCells() {
        let cells = tableView.visibleCells as? [ContactTableViewCell]

        cells?.forEach { cell in
            cell.chatButton.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                cell.chatButton.alpha = 0
                cell.phoneImg.alpha = 0
            })
        }
    }

    // MARK: - Actions

    @IBAction
    func callTypeValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedContacts.removeAll()
            disableMultipleSelection(true)
            hideCallButtonFromNavigationBar(animated: true)
            enableChatAndPhoneButtonsOnVisibleCells()
        } else {
            enableMultipleSelection(true)
            showCallButtonInNavigationBar(animated: true)
            callBarButtonItem?.isEnabled = false
            disableChatAndPhoneButtonsOnVisibleCells()
        }
    }

    @IBAction
    func callBarButtonItemTouched(sender: UIBarButtonItem) {
        startOutgoingCall()
    }

    @IBAction
    func callOptionsBarButtonTouched(sender: UIBarButtonItem) {
        performSegue(withIdentifier: optionsSegueIdentifier, sender: self)
    }

    @IBAction
    func logoutBarButtonTouched(sender: UIBarButtonItem) {
        // When the user sign off, we also close the user session.
        // We highly recommend to close the user session when the end user signs off.
        // Failing to do so, will result in incoming calls and chat messages being processed by the SDK.
        // Moreover the previously logged user will appear to the Bandyer platform as she/he is available and ready to receive calls and chat messages.

        UserSession.currentUser = nil
        KaleyraVideo.instance.disconnect()

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == optionsSegueIdentifier else { return }

        let controller = segue.destination as? CallOptionsTableViewController
        controller?.options = options
        controller?.delegate = self
    }

    // MARK: - Chat ViewController

    private func presentChat(from notification: ChatNotification) {
        guard presentedViewController == nil else { return }
        presentChat(from: self, notification: notification)
    }

    private func presentChat(from controller: UIViewController, notification: ChatNotification) {
        presentChat(from: self, intent: .notification(notification))
    }

    private func presentChat(from controller: UIViewController, intent: ChannelViewController.Intent) {
        let controller = ChannelViewController(intent: intent, configuration: .init())
        controller.delegate = self
        controller.present(controller, animated: true)
    }

    // MARK: - Call ViewController

    private func presentCall(_ call: Call) {
        window.makeKeyAndVisible()
        let controller = CallViewController(call: call, configuration: .init())
        controller.delegate = self
        window.set(rootViewController: controller, animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            alert.dismiss(animated: true)
        }
        alert.addAction(defaultAction)
        self.present(alert, animated: true)
    }

    private func hideCallViewController() {
        window.set(rootViewController: nil, animated: true)
    }

    // MARK: - Navigation items

    private func remove(item: UIBarButtonItem, animated: Bool) {
        guard var items = navigationItem.rightBarButtonItems else { return }
        guard let lastIndex = items.lastIndex(of: item) else { return }

        items.remove(at: lastIndex)
        navigationItem.setRightBarButtonItems(items, animated: animated)
    }
}

// MARK: - Table view data source

extension ContactsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addressBook?.contacts.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactTableViewCell else {
            fatalError("Only ContactTableViewCell type is supported")
        }

        cell.delegate = self

        let contact = addressBook?.contacts[indexPath.row]

        cell.titleLabel.text = contact?.fullName
        cell.subtitleLabel.text = contact?.userID

        if tableView.allowsMultipleSelection {
            cell.chatButton.isEnabled = false
            cell.chatButton.alpha = 0
            cell.phoneImg.alpha = 0
        } else {
            cell.chatButton.isEnabled = true
            cell.chatButton.alpha = 1
            cell.phoneImg.alpha = 1
        }

        return cell
    }
}

// MARK: - Table view delegate
extension ContactsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bindSelectionOfContact(fromRowAt: indexPath)

        if !tableView.allowsMultipleSelection {
            startOutgoingCall()
            tableView.deselectRow(at: indexPath, animated: true)
            selectedContacts.removeAll()
        }
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard tableView.allowsMultipleSelection else { return indexPath }

        bindSelectionOfContact(fromRowAt: indexPath)

        return indexPath
    }

    private func bindSelectionOfContact(fromRowAt indexPath: IndexPath) {
        if let index = selectedContacts.lastIndex(of: indexPath) {
            selectedContacts.remove(at: index)
        } else {
            selectedContacts.append(indexPath)
        }

        callBarButtonItem?.isEnabled = selectedContacts.count > 1
    }
}

// MARK: - Call client observer

extension ContactsViewController {

    func callClientDidChangeState(_ state: ClientState) {
        switch state {
            case .disconnected:
                return
            case .connecting:
                callClientDidStart()
            case .connected:
                view.isUserInteractionEnabled = true
            case .reconnecting:
                callClientDidStartReconnecting()
        }
    }

    private func callClientDidStart() {
        view.isUserInteractionEnabled = false
        hideActivityIndicatorFromNavigationBar(animated: true)
        hideToast()
    }

    private func callClientDidStartReconnecting() {
        view.isUserInteractionEnabled = false
        showActivityIndicatorInNavigationBar(animated: true)
        showToast(message: "Client is reconnecting, please wait...", color: UIColor.orange)
    }
}

// MARK: - Activity indicator nav bar

extension ContactsViewController {

    func showActivityIndicatorInNavigationBar(animated: Bool) {
        guard activityBarButtonItem == nil else { return }

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)

        var items = navigationItem.rightBarButtonItems ?? []
        items.insert(item, at: 0)

        navigationItem.setRightBarButtonItems(items, animated: animated)
        activityBarButtonItem = item
    }

    func hideActivityIndicatorFromNavigationBar(animated: Bool) {
        guard let item = activityBarButtonItem else { return }

        remove(item: item, animated: animated)
    }
}

// MARK: - Call button nav bar

extension ContactsViewController {

    func showCallButtonInNavigationBar(animated: Bool) {
        guard callBarButtonItem == nil else { return }

        let item = UIBarButtonItem(image: UIImage(named: "phone"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(callBarButtonItemTouched(sender:)))

        var items = navigationItem.rightBarButtonItems ?? []
        items.append(item)

        navigationItem.setRightBarButtonItems(items, animated: animated)
        callBarButtonItem = item
    }

    func hideCallButtonFromNavigationBar(animated: Bool) {
        guard let item = callBarButtonItem else { return }

        remove(item: item, animated: animated)
    }
}

// MARK: - Toast

extension ContactsViewController {

    func showToast(message: String, color: UIColor) {
        hideToast()

        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = color

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 7)
        label.text = message

        container.addSubview(label)
        view.addSubview(container)
        toastView = container

        let constraints = [label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                           label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                           container.topAnchor.constraint(equalTo: tableView.topAnchor),
                           container.leftAnchor.constraint(equalTo: view.leftAnchor),
                           container.rightAnchor.constraint(equalTo: view.rightAnchor),
                           container.heightAnchor.constraint(equalToConstant: 16)]

        NSLayoutConstraint.activate(constraints)

    }

    func hideToast() {
        toastView?.removeFromSuperview()
    }
}

// MARK: - Call options controller delegate

extension ContactsViewController: CallOptionsTableViewControllerDelegate {

    func controllerDidUpdateOptions(_ controller: CallOptionsTableViewController) {
        options = controller.options
    }
}

// MARK: - Call window delegate

extension ContactsViewController: CallViewControllerDelegate {

    func callViewControllerDidFinish(_ controller: CallViewController) {
        hideCallViewController()
    }
}

//MARK: Channel view controller delegate

extension ContactsViewController: ChannelViewControllerDelegate {

    func channelViewControllerDidFinish(_ controller: ChannelViewController) {
        controller.dismiss(animated: true)
    }

    func channelViewController(_ controller: ChannelViewController, didTapAudioCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioUpgradable)
    }

    func channelViewController(_ controller: ChannelViewController, didTapVideoCallWith users: [String]) {
        dismiss(channelViewController: controller, presentCallViewControllerWith: users, type: .audioVideo)
    }

    private func dismiss(channelViewController: ChannelViewController, presentCallViewControllerWith callees: [String], type: CallOptions.CallType) {
        let presentedChannelVC = presentedViewController as? ChannelViewController

        if presentedChannelVC != nil {
            channelViewController.dismiss(animated: true) { [weak self] in
                self?.startOutgoingCall(callees: callees, options: .init(type: type))
            }
            return
        }

        startOutgoingCall(callees: callees, options: .init(type: type))
    }
}

// MARK: - Contact table view cell delegate

extension ContactsViewController: ContactTableViewCellDelegate {

    func contactTableViewCell(_ cell: ContactTableViewCell, didTouch chatButton: UIButton, withCounterpart aliasId: String) {
        presentChat(from: self, intent: .participant(id: aliasId))
    }
}

// MARK: - In App file share notification touch listener delegate

extension ContactsViewController: InAppChatNotificationTouchListener {
    
    func onTouch(_ notification: ChatNotification) {
        if presentedViewController is ChannelViewController {
            presentedViewController?.dismiss(animated: true) { [weak self] in
                self?.presentChat(from: notification)
            }
        } else {
            presentChat(from: notification)
        }
    }
}
