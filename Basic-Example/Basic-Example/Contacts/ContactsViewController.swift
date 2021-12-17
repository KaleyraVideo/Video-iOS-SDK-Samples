//
// Copyright © 2018-Present. Kaleyra S.p.a. All rights reserved.
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
    @IBOutlet private var callBarButtonItem: UIBarButtonItem?
    @IBOutlet private var logoutBarButtonItem: UIBarButtonItem!
    @IBOutlet private var userBarButtonItem: UIBarButtonItem!

    private var toastView: UIView?

    private var callWindow: CallWindow?

    var addressBook: AddressBook?

    private var selectedContacts: [IndexPath] = []
    private var options: CallOptionsItem = CallOptionsItem()
    private var intent: Intent?

    //MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        userBarButtonItem.title = UserSession.currentUser
        disableMultipleSelection(false)

        //When view loads we register as a call client observer, in order to receive notifications about incoming calls received and client state changes.
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

    // MARK: - In-app Notification
    
    private func setupNotificationsCoordinator() {
        BandyerSDK.instance().notificationsCoordinator?.fileShareListener = self
        BandyerSDK.instance().notificationsCoordinator?.start()
    }
    
    private func disableNotificationsCoordinator() {
        BandyerSDK.instance().notificationsCoordinator?.stop()
    }
    
    // MARK: - Calls

    private func startOutgoingCall() {

        //To start an outgoing call we must create a `StartOutgoingCallIntent` object specifying who we want to call, the type of call we want to be performed, along with any call option.

        //Here we create the array containing the "user aliases" we want to contact.
        let aliases = selectedContacts.compactMap { (contactIndex) -> String? in
            addressBook?.contacts[contactIndex.row].alias
        }

        //Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
        //The record flag specifies whether we want the call to be recorded or not.
        //The maximumDuration parameter specifies how long the call can last.
        //If you provide 0, the call will be created without a maximum duration value.
        //We store the intent for later use, because we can present again the CallViewController with the same call.
       
        intent = StartOutgoingCallIntent(callees: aliases,
                                         options: CallOptions(callType: options.type,
                                                              recorded: options.record,
                                                              duration: options.maximumDuration))

        //Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    private func receiveIncomingCall(call: Call) {

        //When the client detects an incoming call it will notify its observers through this method.
        //Here we are creating an `HandleIncomingCallIntent` object, storing it for later use.
        intent = HandleIncomingCallIntent(call: call)
        
        //Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    //MARK: Enable / Disable multiple selection

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

    // MARK: - Actions

    @IBAction func callTypeValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedContacts.removeAll()
            disableMultipleSelection(true)
            hideCallButtonFromNavigationBar(animated: true)
        } else {
            enableMultipleSelection(true)
            showCallButtonInNavigationBar(animated: true)
            callBarButtonItem?.isEnabled = false
        }
    }

    @IBAction func callBarButtonItemTouched(sender: UIBarButtonItem) {
        startOutgoingCall()
    }

    @IBAction func callOptionsBarButtonTouched(sender: UIBarButtonItem) {
        performSegue(withIdentifier: optionsSegueIdentifier, sender: self)
    }

    @IBAction func logoutBarButtonTouched(sender: UIBarButtonItem) {
        //When the user sign off, we also stop the client.
        //We highly recommend to close the session when the end user signs off
        //Failing to do so, will result in incoming calls being processed by the SDK.
        //Moreover the previously logged user will appear to the Bandyer platform as she/he is available and ready to receive calls.

        UserSession.currentUser = nil
        BandyerSDK.instance().closeSession()

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation to other screens

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == optionsSegueIdentifier {
            let controller = segue.destination as? CallOptionsTableViewController
            controller?.options = options
            controller?.delegate = self
        }
    }

    // MARK: - Present Call ViewController

    private func performCallViewControllerPresentation() {
        guard let intent = self.intent else {
            return
        }

        prepareForCallViewControllerPresentation()

        //Here we tell the call window what it should do and we present the CallViewController if there is no another call in progress and if the CallViewController is configured.
        //Otherwise you should manage the behaviour, for example with a UIAlert warning.
        
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

        //Here we are configuring the CallViewController instance.
        //A `CallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
        let config = CallViewControllerConfiguration()

        let filePath = Bundle.main.path(forResource: "SampleVideo_640x360_10mb", ofType: "mp4")

        guard let path = filePath else {
            fatalError("The fake file for the file capturer could not be found")
        }

        //This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
        let url = URL(fileURLWithPath: path)
        config.fakeCapturerFileURL = url

        //Here, we set the configuration object created. You must set the view controller configuration object before the view controller
        //view is loaded, otherwise an exception is thrown.
        callWindow?.setConfiguration(config)
    }

    private func initCallWindowIfNeeded() {
        //Please remember to reference the call window only once in order to avoid the reset of CallViewController.
        guard callWindow == nil else { return }

        //Please be sure to have in memory only one instance of CallWindow, otherwise an exception will be thrown.
        let window: CallWindow

        if let instance = CallWindow.instance {
            window = instance
        } else {
            //This will automatically save the new instance inside CallWindow.instance.
            window = CallWindow()
        }

        //Remember to subscribe as the delegate of the window. The window  will notify its delegate when it has finished its job.
        window.callDelegate = self

        callWindow = window
    }

    // MARK: - Hide Call ViewController

    private func hideCallViewController() {
        callWindow?.isHidden = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let contact = addressBook?.contacts[indexPath.row]
        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.text = contact?.fullName
            config.secondaryText = contact?.alias
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = contact?.fullName
            cell.detailTextLabel?.text = contact?.alias
        }

        let image = UIImage(named: "phone")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        cell.accessoryView = imageView

        return cell
    }
}

// MARK: - Table view delegate

extension ContactsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bindSelectionOfContact(fromRowAt: indexPath)
        guard !tableView.allowsMultipleSelection else { return }

        startOutgoingCall()
        tableView.deselectRow(at: indexPath, animated: true)
        selectedContacts.removeAll()
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
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        navigationItem.setRightBarButton(item, animated: animated)
    }

    func hideActivityIndicatorFromNavigationBar(animated: Bool) {
        guard let indicator = navigationItem.rightBarButtonItem?.customView else { return }
        guard indicator is UIActivityIndicatorView else { return }

        navigationItem.setRightBarButton(nil, animated: animated)
    }
}

// MARK: - Call button nav bar

extension ContactsViewController {

    func showCallButtonInNavigationBar(animated: Bool) {
        let item = UIBarButtonItem(image: UIImage(named: "phone"), style: .plain, target: self, action: #selector(callBarButtonItemTouched(sender:)))
        navigationItem.setRightBarButton(item, animated: animated)
        callBarButtonItem = item
    }

    func hideCallButtonFromNavigationBar(animated: Bool) {
        navigationItem.setRightBarButton(nil, animated: animated)
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
        //Do nothing since chat is not supported on this project
    }
}

// MARK: - In App file share notification touch listener delegate

extension ContactsViewController: InAppFileShareNotificationTouchListener {
    
    func onTouch(_ notification: FileShareNotification) {
        callWindow?.presentCallViewController(for: OpenDownloadsIntent())
    }
}
