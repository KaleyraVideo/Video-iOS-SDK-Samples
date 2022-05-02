//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit
import Bandyer

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

    private var callWindow: CallWindow?

    var addressBook: AddressBook?

    private var selectedContacts: [IndexPath] = []
    private var options: CallOptionsItem = CallOptionsItem()
    private var intent: Intent?

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        userBarButtonItem.title = UserSession.currentUser
        disableMultipleSelection(false)

        // When view loads we register as a client observer, in order to receive notifications about received incoming calls and client state changes.
        BandyerSDK.instance().callClient.add(observer: self, queue: .main)
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
        BandyerSDK.instance().notificationsCoordinator?.chatListener = self
        BandyerSDK.instance().notificationsCoordinator?.fileShareListener = self
        BandyerSDK.instance().notificationsCoordinator?.start()
    }

    private func disableNotificationsCoordinator() {
        BandyerSDK.instance().notificationsCoordinator?.stop()
    }

    // MARK: - Starting or receiving a call

    private func startOutgoingCall() {
        // To start an outgoing call we must create a `StartOutgoingCallIntent` object specifying who we want to call,
        // the type of call we want to be performed, along with any call option.

        // Here we create the array containing the "user aliases" we want to contact.
        let aliases = selectedContacts.compactMap { (contactIndex) -> String? in
            addressBook?.contacts[contactIndex.row].alias
        }

        // Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
        // The record flag specifies whether we want the call to be recorded or not.
        // The maximumDuration parameter specifies how long the call can last.
        // If you provide 0, the call will be created without a maximum duration value.
        // We store the intent for later use, because we can present again the CallViewController with the same call.
        intent = StartOutgoingCallIntent(callees: aliases,
                                         options: CallOptions(callType: options.type,
                                                              recorded: options.record,
                                                              duration: options.maximumDuration))

        // Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    private func receiveIncomingCall(call: Call) {
        // When the client detects an incoming call it will notify its observers through this method.
        // Here we are creating an `HandleIncomingCallIntent` object, storing it for later use,
        // then we trigger a presentation of CallViewController.
        intent = HandleIncomingCallIntent(call: call)
        performCallViewControllerPresentation()
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
        BandyerSDK.instance().closeSession()

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
        if presentedViewController == nil {
            presentChat(from: self, notification: notification)
        }
    }

    private func presentChat(from controller: UIViewController, notification: ChatNotification) {
        guard let intent = OpenChatIntent.openChat(from: notification) else {
            return
        }
        presentChat(from: self, intent: intent)
    }

    private func presentChat(from controller: UIViewController, intent: OpenChatIntent) {
        let channelViewController = ChannelViewController()
        channelViewController.delegate = self
        channelViewController.intent = intent

        controller.present(channelViewController, animated: true)
    }

    // MARK: - Call ViewController

    private func performCallViewControllerPresentation() {
        guard let intent = self.intent else { return }
        
        prepareForCallViewControllerPresentation()
        
        // Here we tell the call window to present the Call UI if there is not another call in progress.
        // Otherwise you should handle the error notified as the closure argument.
        
        callWindow?.presentCallViewController(for: intent) { [weak self] error in
            guard let error = error else { return }
            guard let self = self else { return }
            
            switch error {
            case let presentationError as CallPresentationError where presentationError.errorCode == CallPresentationErrorCode.anotherCallOnGoing.rawValue:
                self.presentAlert(title: "Warning", message: "Another call ongoing.")
            default:
                self.presentAlert(title: "Error", message: "Impossible to start a call now. Try again later.")
            }
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            alert.dismiss(animated: true)
        }
        alert.addAction(defaultAction)
        self.present(alert, animated: true)
    }

    private func prepareForCallViewControllerPresentation() {
        initCallWindowIfNeeded()

        // Here we are configuring the CallViewController instance.
        // A `CallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
        let config = CallViewControllerConfiguration()

        let filePath = Bundle.main.path(forResource: "SampleVideo_640x360_10mb", ofType: "mp4")

        guard let path = filePath else {
            fatalError("The fake file for the file capturer could not be found")
        }

        // This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
        let url = URL(fileURLWithPath: path)
        config.fakeCapturerFileURL = url

        let customizeUI = false

        if customizeUI {
            //Comment this line or set the value to NO to disable the call feedback popup
            config.isFeedbackEnabled = true

            //Let's suppose that you want to change the navBarTitleFont only inside the BDKCallViewController.
            //You can achieve this result by allocate a new instance of the theme and set the navBarTitleFont property whit the wanted value.
            let callTheme = Theme()
            callTheme.navBarTitleFont = .robotoBold.withSize(30)

            config.callTheme = callTheme

            //The same reasoning will let you change the accentColor only inside the Whiteboard view controller.
            let whiteboardTheme = Theme()
            whiteboardTheme.accentColor = .systemBlue

            config.whiteboardTheme = whiteboardTheme

            //You can also customize the theme only of the Whiteboard text editor view controller.
            let whiteboardTextEditorTheme = Theme()
            whiteboardTextEditorTheme.bodyFont = .robotoThin.withSize(30)

            config.whiteboardTextEditorTheme = whiteboardTextEditorTheme

            //In the next lines you can see how it's possible to customize the File Sharing view controller theme.
            let fileSharingTheme = Theme()
            //By setting a point size property of the theme you can change the point size of all the medium/large labels.
            fileSharingTheme.mediumFontPointSize = 20
            fileSharingTheme.largeFontPointSize = 40

            config.fileSharingTheme = fileSharingTheme

            // In the same way as other themes, you can customize the appearance of the call feedback popup by creating a new instance of Theme
            let feedbackTheme = Theme()
            // Setting the accentColor property with the desired value will modify the color of the stars and the background color of the submit button
            feedbackTheme.accentColor = .systemGreen
            // You can also customize the font and emphasisFont properties
            feedbackTheme.font = .robotoThin
            feedbackTheme.emphasisFont = .robotoBold

            config.feedbackTheme = feedbackTheme

            // The delay in seconds after which the feedback popup is automatically dismissed when the user leaves a feedback.
            config.feedbackAutoDismissDelay = 5

            // Every single string in the feedback popup is customizable.
            // To make this customization just pass the bundle containing the localization with the right keys valorized, as in this example.
            config.assetsBundle = .main
            // If your file is named 'Localizable' you don't need to set this value, otherwise provide the filename
            config.localizationTableName = "ExampleLocalizable"

            //You can also format the way our SDK displays the user information inside the call page. In this example, the user info will be preceded by a percentage.
            config.callInfoTitleFormatter = PercentageFormatter()
        }

        // Here, we set the configuration object created. You must set the view controller configuration object before the view controller
        // view is loaded, otherwise an exception is thrown.
        callWindow?.setConfiguration(config)
    }

    private func initCallWindowIfNeeded() {
        // Please remember to reference the call window only once in order to avoid the reset of CallViewController.
        guard callWindow == nil else { return }

        // Please be sure to have in memory only one instance of CallWindow, otherwise an exception will be thrown.
        let window: CallWindow

        if let instance = CallWindow.instance {
            window = instance
        } else {
            // This will automatically save the new instance inside CallWindow.instance.
            window = CallWindow()
        }

        // Remember to subscribe as the delegate of the window. The window  will notify its delegate when it has finished its job.
        window.callDelegate = self

        callWindow = window
    }

    private func hideCallViewController() {
        callWindow?.isHidden = true
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
        cell.subtitleLabel.text = contact?.alias

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

extension ContactsViewController: CallClientObserver {

    func callClient(_ client: CallClient, didReceiveIncomingCall call: Call) {
        receiveIncomingCall(call: call)
    }

    func callClientDidStart(_ client: CallClient) {
        view.isUserInteractionEnabled = false
        hideActivityIndicatorFromNavigationBar(animated: true)
        hideToast()
    }

    func callClientDidStartReconnecting(_ client: CallClient) {
        view.isUserInteractionEnabled = false
        showActivityIndicatorInNavigationBar(animated: true)
        showToast(message: "Client is reconnecting, please wait...", color: UIColor.orange)
    }

    func callClientWillResume(_ client: CallClient) {
        view.isUserInteractionEnabled = false
        showActivityIndicatorInNavigationBar(animated: true)
        showToast(message: "Client is resuming, please wait...", color: UIColor.orange)
    }

    func callClientDidResume(_ client: CallClient) {
        view.isUserInteractionEnabled = true
        hideActivityIndicatorFromNavigationBar(animated: true)
        hideToast()
    }
}

// MARK: - Activity indicator nav bar

extension ContactsViewController {

    func showActivityIndicatorInNavigationBar(animated: Bool) {
        guard activityBarButtonItem == nil else { return }

        let indicator = UIActivityIndicatorView(style: .gray)
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
        callBarButtonItem = nil
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

extension ContactsViewController: CallWindowDelegate {

    func callWindowDidFinish(_ window: CallWindow) {
        hideCallViewController()
    }

    func callWindow(_ window: CallWindow, openChatWith intent: OpenChatIntent) {
        presentChat(from: self, intent: intent)
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

    private func dismiss(channelViewController: ChannelViewController, presentCallViewControllerWith callees: [String], type: CallType) {
        let presentedChannelVC = presentedViewController as? ChannelViewController

        if presentedChannelVC != nil {
            channelViewController.dismiss(animated: true) { [weak self] in
                self?.intent = StartOutgoingCallIntent(callees: callees, options: CallOptions(callType: type))
                self?.performCallViewControllerPresentation()
            }
            return
        }

        intent = StartOutgoingCallIntent(callees: callees, options: CallOptions(callType: type))
        performCallViewControllerPresentation()
    }
}

// MARK: - Contact table view cell delegate

extension ContactsViewController: ContactTableViewCellDelegate {

    func contactTableViewCell(_ cell: ContactTableViewCell, didTouch chatButton: UIButton, withCounterpart aliasId: String) {
        let intent = OpenChatIntent.openChat(with: aliasId)
        presentChat(from: self, intent: intent)
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

// MARK: - In App file share notification touch listener delegate

extension ContactsViewController: InAppFileShareNotificationTouchListener {

    func onTouch(_ notification: FileShareNotification) {
        callWindow?.presentCallViewController(for: OpenDownloadsIntent())
    }
}
