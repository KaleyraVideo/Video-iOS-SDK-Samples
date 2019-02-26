//
// Created by Marco Brescianini on 2019-02-26.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import UIKit
import BandyerSDK

class ContactsViewController: UIViewController {

    //MARK: Constants
    private let cellIdentifier = "userCellId"
    private let optionsSegueIdentifier = "showOptionsSegue"
    private let callSegueIdentifier = "showCallSegue"

    //MARK: Outlets and subviews

    @IBOutlet private var tableView:UITableView!
    @IBOutlet private var callTypeControl:UISegmentedControl!
    @IBOutlet private var callOptionsBarButtonItem: UIBarButtonItem!
    @IBOutlet private var logoutBarButtonItem: UIBarButtonItem!
    @IBOutlet private var userBarButtonItem: UIBarButtonItem!
    private var callBarButtonItem: UIBarButtonItem?
    private var activityBarButtonItem: UIBarButtonItem?
    private var toastView: UIView?

    var addressBook: AddressBook?

    private var selectedContacts:[IndexPath] = []
    private var options:CallOptionsItem = CallOptionsItem()
    private var intent: BDKIntent?

    //MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        userBarButtonItem.title = UserSession.currentUser
        disableMultipleSelection(false)

        //When view loads we register as a client observer, in order to receive notifications about incoming calls received and client state changes.
        BandyerSDK.instance().callClient.add(self, queue: DispatchQueue.main)
    }

    //MARK: Calls

    func startOutgoingCall(){

        //To start an outgoing call we must create a `BDKMakeCallIntent` object specifying who we want to call, the type of call
        //we want to be performed, along with any call option.

        var aliases:[String] = []

        //Here we create the array containing the "user aliases" we want to contact.
        for contactIndex in selectedContacts {
            let alias: String = (addressBook?.contacts[contactIndex.row].alias)!
            aliases.append(alias)
        }

        //Then we create the intent providing the aliases array (which is a required parameter) along with the type of call we want perform.
        //The record flag specifies whether we want the call to be recorded or not.
        //The maximumDuration parameter specifies how long the call can last.
        //If you provide 0, the call will be created without a maximum duration value.
        //We store the intent for later use, because we are using storyboards. When this view controller is asked to prepare for segue
        //we are going to hand the intent to the `BDKCallViewController` created by the storyboard

        intent = BDKMakeCallIntent(callee: aliases, type: options.type, record: options.record, maximumDuration: options.maximumDuration)

        //Then we trigger a segue to a BDKCallViewController.
        performSegue(withIdentifier: callSegueIdentifier, sender: self)
    }

    func receiveIncomingCall(){

        //When the client detects an incoming call it will notify its observers through this method.
        //Here we are creating an `BDKIncomingCallHandlingIntent` object, storing it for later use,
        //then we trigger a segue to a BDKCallViewController.
        intent = BDKIncomingCallHandlingIntent()
        performSegue(withIdentifier: callSegueIdentifier, sender: self)

        //If you don't use a storyboard you should create a BDKCallViewController instance, configure it, hand it the intent object created
        //Finally you can present it.
    }

    //MARK: Enable / Disable multiple selection

    func enableMultipleSelection(_ animated:Bool){
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.setEditing(true, animated: animated)
    }

    func disableMultipleSelection(_ animated:Bool){
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false

        tableView.setEditing(false, animated: animated)
    }


    //MARK: Actions
    @IBAction func callTypeValueChanged(sender:UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            selectedContacts.removeAll()
            disableMultipleSelection(true)
            hideCallButtonFromNavigationBar(animated: true)
        } else {
            enableMultipleSelection(true)
            showCallButtonInNavigationBar(animated: true)
        }
    }

    @IBAction func callBarButtonItemTouched(sender:UIBarButtonItem){
        startOutgoingCall()
    }

    @IBAction func callOptionsBarButtonTouched(sender: UIBarButtonItem){
        performSegue(withIdentifier: optionsSegueIdentifier, sender: self)
    }

    @IBAction func logoutBarButtonTouched(sender: UIBarButtonItem){
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
        } else if segue.identifier == callSegueIdentifier {

            //Here we are configuring the BDKCallViewController instance created from the storyboard.
            //A `BDKCallViewControllerConfiguration` object instance is needed to customize the behaviour and appearance of the view controller.
            let config = BDKCallViewControllerConfiguration()

            let filePath = Bundle.main.path(forResource: "SampleVideo_640x360_10mb", ofType: "mp4")

            guard let path = filePath else {
                fatalError("The fake file for the file capturer could not be found")
            }

            //This url points to a sample mp4 video in the app bundle used only if the application is run in the simulator.
            let url = URL(fileURLWithPath:path)
            config.fakeCapturerFileURL = url

            //This statement tells the view controller which object, conforming to `BDKUserInfoFetcher` protocol, should use to present contact
            //information in its views.
            //The backend system does not send any user information to its clients, the SDK and the backend system identify the users in a call
            //using their user aliases, it is your responsibility to match "user aliases" with the corresponding user object in your system
            //and provide those information to the view controller
            config.userInfoFetcher = UserInfoFetcher(addressBook!)

            let controller = segue.destination as! BDKCallViewController

            //Remember to subscribe as the delegate of the view controller. The view controller will notify its delegate when it has finished its
            //job
            controller.delegate = self

            //Here, we set the configuration object created. You must set the view controller configuration object before the view controller
            //view is loaded, otherwise an exception is thrown.
            controller.setConfiguration(config)

            //Then we tell the view controller what it should do.
            controller.handle(intent!)

        }
    }
}

//MARK: Table view data source
extension ContactsViewController : UITableViewDataSource{

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressBook!.contacts.count
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
extension ContactsViewController : UITableViewDelegate{
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if selectedContacts.contains(indexPath){
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
extension ContactsViewController : BCXCallClientObserver{

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
        showToast(message:"Client is reconnecting, please wait...", color:UIColor.orange)
    }

    public func callClientWillResume(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = false
        showActivityIndicatorInNavigationBar(animated: true)
        showToast(message:"Client is resuming, please wait...", color:UIColor.orange)
    }

    public func callClientDidResume(_ client: BCXCallClient) {
        view.isUserInteractionEnabled = true
        hideActivityIndicatorFromNavigationBar(animated: true)
        hideToast()
    }
}

//MARK: Activity indicator nav bar
extension ContactsViewController {

    func showActivityIndicatorInNavigationBar(animated: Bool){
        guard activityBarButtonItem == nil else {
            return
        }

        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)

        var items = navigationItem.rightBarButtonItems ?? []
        items.insert(item, at: 0)

        navigationItem.setRightBarButtonItems(items, animated: animated)
        activityBarButtonItem = item
    }

    func hideActivityIndicatorFromNavigationBar(animated: Bool){

        guard let item = activityBarButtonItem else {
            return
        }

        guard var items = navigationItem.rightBarButtonItems else {
            return
        }

        if items.contains(item) {
            items.remove(at: items.lastIndex(of: item)!)
            navigationItem.setRightBarButtonItems(items, animated: animated)
        }
    }
}

//MARK: Call button nav bar
extension ContactsViewController {

    func showCallButtonInNavigationBar(animated:Bool){
        guard callBarButtonItem == nil else {
            return
        }

        let item = UIBarButtonItem(image: UIImage(named: "phone"), style: .plain, target: self, action: #selector(callBarButtonItemTouched(sender:)))

        var items = navigationItem.rightBarButtonItems ?? []
        items.append(item)

        navigationItem.setRightBarButtonItems(items, animated: animated)
        callBarButtonItem = item
    }

    func hideCallButtonFromNavigationBar(animated:Bool){

        guard let item = callBarButtonItem else {
            return
        }

        guard var items = navigationItem.rightBarButtonItems else{
            return
        }

        if (items.contains(item)){
            items.remove(at: items.lastIndex(of: item)!)
            navigationItem.setRightBarButtonItems(items, animated: animated)
        }
    }
}

//MARK: Toast
extension ContactsViewController{

    func showToast(message:String, color:UIColor){
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

        label.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true

        container.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: 16).isActive = true

    }

    func hideToast(){
        toastView?.removeFromSuperview()
    }
}

//MARK: Call view controller delegate
extension ContactsViewController : BDKCallViewControllerDelegate{
    public func callViewControllerDidFinish(_ controller: BDKCallViewController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Call options controller delegate
extension ContactsViewController : CallOptionsTableViewControllerDelegate {
    func controllerDidUpdateOptions(_ controller: CallOptionsTableViewController) {
        options = controller.options
    }
}
