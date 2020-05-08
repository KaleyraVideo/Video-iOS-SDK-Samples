//
// Created by Marco Brescianini on 2019-02-26.
// Copyright (c) 2019 Bandyer. All rights reserved.
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
    private var intent: BDKIntent?

    private let callBannerController = CallBannerController()

    //MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        //When view loads we have to setup custom view controller.
        setupCallBannerView()

        userBarButtonItem.title = UserSession.currentUser
        disableMultipleSelection(false)

        //When view loads we register as a call client observer, in order to receive notifications about incoming calls received and client state changes.
        BandyerSDK.instance().callClient.add(observer: self, queue: .main)
    }

    private func setupCallBannerView() {
        callBannerController.delegate = self
        callBannerController.parentViewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        callBannerController.show()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        callBannerController.hide()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        //Remember to call viewWillTransitionTo on custom view controller to update UI while rotating.
        callBannerController.viewWillTransition(to: size, withTransitionCoordinator: coordinator)

        super.viewWillTransition(to: size, with: coordinator)
    }

    //MARK: Calls

    func startOutgoingCall() {

        //To start an outgoing call we must create a `BDKMakeCallIntent` object specifying who we want to call, the type of call we want to be performed, along with any call option.

        //Here we create the array containing the "user aliases" we want to contact.
        let aliases = selectedContacts.compactMap { (contactIndex) -> String? in
            addressBook?.contacts[contactIndex.row].alias
        }

        //Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
        //The record flag specifies whether we want the call to be recorded or not.
        //The maximumDuration parameter specifies how long the call can last.
        //If you provide 0, the call will be created without a maximum duration value.
        //We store the intent for later use, because we can present again the CallViewController with the same call.
        intent = BDKMakeCallIntent(callee: aliases, type: options.type, record: options.record, maximumDuration: options.maximumDuration)

        //Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    func receiveIncomingCall() {

        //When the client detects an incoming call it will notify its observers through this method.
        //Here we are creating an `BDKIncomingCallHandlingIntent` object, storing it for later use.
        intent = BDKIncomingCallHandlingIntent()
        //Then we trigger a presentation of CallViewController.
        performCallViewControllerPresentation()
    }

    //MARK: Enable / Disable multiple selection

    func enableMultipleSelection(_ animated: Bool) {
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.setEditing(true, animated: animated)
    }

    func disableMultipleSelection(_ animated: Bool) {
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false

        tableView.setEditing(false, animated: animated)
    }

    //MARK: Actions
    @IBAction func callTypeValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedContacts.removeAll()
            disableMultipleSelection(true)
            hideCallButtonFromNavigationBar(animated: true)
        } else {
            enableMultipleSelection(true)
            showCallButtonInNavigationBar(animated: true)
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
        //We highly recommend to stop the client when the end user signs off
        //Failing to do so, will result in incoming calls being processed by the SDK.
        //Moreover the previously logged user will appear to the Bandyer platform as she/he is available and ready to receive calls.

        UserSession.currentUser = nil
        BandyerSDK.instance().callClient.stop()

        dismiss(animated: true, completion: nil)
    }

    //MARK: Navigation to other screens
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == optionsSegueIdentifier {
            let controller = segue.destination as! CallOptionsTableViewController
            controller.options = options
            controller.delegate = self
        }
    }

    //MARK: Present Call ViewController

    private func performCallViewControllerPresentation() {

        prepareForCallViewControllerPresentation()

        //Here we tell the call window what it should do and we present the CallViewController if there is no another call in progress.
        //Otherwise you should manage the behaviour, for example with a UIAlert warning.

        callWindow?.shouldPresentCallViewController(intent: intent, completion: { [weak self] succeeded in
            if (!succeeded) {
                let alert = UIAlertController(title: "Warning", message: "Another call ongoing.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    alert.dismiss(animated: true)
                }
                alert.addAction(defaultAction)
                self?.present(alert, animated: true)
            }
        })
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

        //This statement tells the view controller which object, conforming to `UserInfoFetcher` protocol, should use to present contact
        //information in its views.
        //The backend system does not send any user information to its clients, the SDK and the backend system identify the users in a call
        //using their user aliases, it is your responsibility to match "user aliases" with the corresponding user object in your system
        //and provide those information to the view controller.
        config.userInfoFetcher = UserInfoFetcher(addressBook!)

        //Here, we set the configuration object created. You must set the view controller configuration object before the view controller
        //view is loaded, otherwise an exception is thrown.
        callWindow?.setConfiguration(config)
    }

    private func initCallWindowIfNeeded() {
        //Please remember to reference the call window only once in order to avoid the reset of CallViewController.
        guard callWindow == nil else {
            return
        }

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

    //MARK: Hide Call ViewController

    private func hideCallViewController() {
        callWindow?.isHidden = true
    }

    //MARK: StatusBar appearance

    private func restoreStatusBarAppearance() {
        let rootNavigationController = navigationController as? ContactsNavigationController
        rootNavigationController?.restoreStatusBarAppearance()
    }

    private func setStatusBarAppearanceToLight() {
        let rootNavigationController = navigationController as? ContactsNavigationController
        rootNavigationController?.setStatusBarAppearance(.lightContent)
    }
}

//MARK: Table view data source
extension ContactsViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addressBook!.contacts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let contact = addressBook?.contacts[indexPath.row]
        cell.textLabel?.text = contact?.fullName
        cell.detailTextLabel?.text = contact?.alias

        let image = UIImage(named: "phone")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        cell.accessoryView = imageView

        return cell
    }
}

//MARK: Table view delegate
extension ContactsViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if selectedContacts.contains(indexPath) {
            selectedContacts.remove(at: selectedContacts.lastIndex(of: indexPath)!)
        } else {
            selectedContacts.append(indexPath)
        }

        callBarButtonItem?.isEnabled = selectedContacts.count > 1

        if !tableView.allowsMultipleSelection {
            startOutgoingCall()
            tableView.deselectRow(at: indexPath, animated: true)
            selectedContacts.removeAll()
        }
    }
}

//MARK: Call client observer
extension ContactsViewController: BCXCallClientObserver {

    public func callClient(_ client: BCXCallClient, didReceiveIncomingCall call: BCXCall) {
        receiveIncomingCall()
    }

    public func callClientDidStart(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = false
        hideActivityIndicatorFromNavigationBar(animated: true)
        hideToast()
    }

    public func callClientDidStartReconnecting(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = false
        showActivityIndicatorInNavigationBar(animated: true)
        showToast(message: "Client is reconnecting, please wait...", color: UIColor.orange)
    }

    public func callClientWillResume(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = false
        showActivityIndicatorInNavigationBar(animated: true)
        showToast(message: "Client is resuming, please wait...", color: UIColor.orange)
    }

    public func callClientDidResume(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = true
        hideActivityIndicatorFromNavigationBar(animated: true)
        hideToast()
    }
}

//MARK: Activity indicator nav bar
extension ContactsViewController {

    func showActivityIndicatorInNavigationBar(animated: Bool) {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        navigationItem.setRightBarButton(item, animated: animated)
    }

    func hideActivityIndicatorFromNavigationBar(animated: Bool) {
        guard let indicator = navigationItem.rightBarButtonItem?.customView else {
            return
        }

        if indicator is UIActivityIndicatorView {
            navigationItem.setRightBarButton(nil, animated: animated)
        }
    }
}

//MARK: Call button nav bar
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

//MARK: Toast
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

//MARK: Call options controller delegate
extension ContactsViewController: CallOptionsTableViewControllerDelegate {
    func controllerDidUpdateOptions(_ controller: CallOptionsTableViewController) {
        options = controller.options
    }
}

//MARK: Call window delegate
extension ContactsViewController: CallWindowDelegate {
    func callWindowDidFinish(_ window: CallWindow) {
        hideCallViewController()
    }

    func callWindow(_ window: CallWindow, openChatWith intent: OpenChatIntent) {
        //Do nothing since chat is not supported on this project
    }
}

//MARK: Call Banner Controller delegate
extension ContactsViewController: CallBannerControllerDelegate {
    func callBannerController(_ controller: CallBannerController, didTouch banner: CallBannerView) {
        //Please remember to override the current call intent with the one saved inside call window.
        intent = callWindow?.intent
        performCallViewControllerPresentation()
    }

    func callBannerController(_ controller: CallBannerController, willShow banner: CallBannerView) {
        setStatusBarAppearanceToLight()
    }

    func callBannerController(_ controller: CallBannerController, willHide banner: CallBannerView) {
        restoreStatusBarAppearance()
    }
}
