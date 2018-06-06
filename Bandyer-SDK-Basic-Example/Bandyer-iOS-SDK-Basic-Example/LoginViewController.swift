// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCommunicationCenter

class LoginViewController: UIViewController, BCXCallClientObserver {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var login: UIButton?
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------------------------
    
    @IBAction func loginButtonTouched(_ sender: UIButton) {
        
        self.view.isUserInteractionEnabled = false
        self.spinner?.startAnimating()
        
        //Once you have authenticated your user, you are ready to initialize the call client instance.
        //The call client instance is responsible for making outgoing calls and detecting incoming calls.
        //In order to do its job it must connect to Bandyer platform first.
        
        //This statement is needed to register the current view controller as an observer of the call client.
        //When the client has started successfully or it has stopped, it will notify its observers about its state changes.
        BandyerCommunicationCenter.instance().callClient.addObserver(observer: self)
        
        //This statement is needed to initialize the call client, establishing a secure connection with Bandyer platform.
        //In order to do so, a user alias must be provided to authenticate the device.
        //A user alias is an identifier that binds users of your app with users in Bandyer platform.
        //You should have obtained user aliases from your back-end or through the Bandyer REST API.
        
        BandyerCommunicationCenter.instance().callClient.initialize("PUT LOGIN USER ALIAS HERE")
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Call Client Observer
    //-------------------------------------------------------------------------------------------
    
    
    func callClientDidStart(_ client: BCXCallClient) {
        
        //Once the call client has established a secure connection with Bandyer platform and it has been authenticated by the back-end system
        //you are ready to make calls and receive incoming calls.

        self.view.isUserInteractionEnabled = true
        self.spinner?.stopAnimating()
        presentContactsInterface()
        
    }
    
    func callClientDidStop(_ client: BCXCallClient) {
        
        //If the call client cannot establish a connection with Bandyer platform, or it has stopped for any reason, this method will be called.

        self.view.isUserInteractionEnabled = true
        self.spinner?.stopAnimating()
        
    }
    
    private func presentContactsInterface() {
        
        if self.presentedViewController==nil {
            performSegue(withIdentifier: "ShowContactsSegueId", sender: self)
        }
        
    }
    
}
