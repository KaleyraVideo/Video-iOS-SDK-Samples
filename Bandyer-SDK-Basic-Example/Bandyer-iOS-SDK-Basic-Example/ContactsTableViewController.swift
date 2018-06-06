// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCommunicationCenter

class ContactsTableViewController: UITableViewController, BCXCallClientObserver, CallViewControllerDelegate {
    
    @IBOutlet weak var callType: UISegmentedControl!
    @IBOutlet weak var callButton: UIBarButtonItem!
    
    let users: [String] = [String]() //This is the array containing the users from your company, it should be filled with the aliases identifying each user in Bandyer platform.

    var selectedUsers: [String] = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Here we are subscribing as a call client observer. If the client detects an
        //incoming call, it will call our "callClient(_ client: BCXCallClient, didReceiveIncomingCall call: BCXCall)" method implementation.
        BandyerCommunicationCenter.instance().callClient.addObserver(observer: self)
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------------------------

    @IBAction func callTypeDidChange(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex==1) { //Conference
            self.tableView.allowsMultipleSelection = true
            self.tableView.allowsMultipleSelectionDuringEditing = true
            self.tableView.setEditing(true, animated: true)
        } else //Call
        {
            self.tableView.allowsMultipleSelection = false
            self.tableView.setEditing(false, animated: true)
        }
        
    }
    
    @IBAction func callButtonTouched(_ sender: UIBarButtonItem) {
        startCall()
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Table Data Source
    //-------------------------------------------------------------------------------------------
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "userCellId")
        cell?.textLabel?.text = users[indexPath.row]
        return cell!
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Table Delegate
    //-------------------------------------------------------------------------------------------
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = users[indexPath.row]
        if(selectedUsers.contains(selectedUser)) {
            selectedUsers.remove(at: selectedUsers.index(of: selectedUser)!)
        } else {
            selectedUsers.append(users[indexPath.row])
        }
        
        if(!self.tableView.allowsMultipleSelection) {
            startCall()
            self.tableView.deselectRow(at: indexPath, animated: true)
            selectedUsers.removeAll()
        }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Start Call
    //-------------------------------------------------------------------------------------------
    
    private func startCall() {
        
        if(selectedUsers.count>=0) {
            
            self.view.isUserInteractionEnabled = false
            
            //This is how an outgoing call is started. You must provide an array of users alias identifying the contacts your user wants to communicate with.
            //Starting an outgoing call is an asynchronous process, failure or success are reported in the callback provided.
            BandyerCommunicationCenter.instance().callClient.callUsers(selectedUsers, completion: {(_ call: BCXCall?, _ error: Error?) -> Void in
                
                self.view.isUserInteractionEnabled = true

                if !(error==nil) {
                    
                    //If an error occurs the call cannot be performed and an error will be
                    //provided as an argument in this block.
                    self.showCannotCreateCallAlert(error: error)
                    
                } else {
                    
                    //If the call is created successfully, we show the user interface responsible for
                    //handling the call. At this moment you cannot talk with the other users yet,
                    //the back-end system is taking care of notifying them that you want to make a call.
                    self.showCallInterface()
                    
                }
            })
            
        }
        
    }
    
    private func showCannotCreateCallAlert(error: Error?) {
        
        let alertController = UIAlertController(title: "Error while calling: "+self.selectedUsers.description, message: error?.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {() -> Void in }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Call Center observer
    //-------------------------------------------------------------------------------------------
    
    func callClient(_ callCenter: BCXCallClient, didReceiveIncomingCall call: BCXCall) {
        
        //When the call client detects that an incoming call has been received, it will notify its observers through this method.
        //Now we are ready to show the user interface responsible for handling a call.
        showCallInterface()
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Navigation
    //-------------------------------------------------------------------------------------------
    
    private func showCallInterface() {
        if(self.presentedViewController==nil) {
            performSegue(withIdentifier: "showCallSegueId", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="showCallSegueId") {
            let controller = (segue.destination as! CallViewController)
            controller.call = BandyerCommunicationCenter.instance().callClient.ongoingCall!
            controller.delegate = self
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Call View Controller Delegate
    //-------------------------------------------------------------------------------------------
    
    func callControllerDidEnd(controller: CallViewController) {
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
}
