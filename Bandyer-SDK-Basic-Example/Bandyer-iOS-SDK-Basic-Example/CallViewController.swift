// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCommunicationCenter

class CallViewController: UIViewController, BCXCallObserver {
    
    @IBOutlet weak var buttonsContainer: UIStackView?
    @IBOutlet weak var hangUpButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var answerButton: UIButton?
    @IBOutlet weak var declineButton: UIButton?
    
    weak var delegate: CallViewControllerDelegate? = nil
    
    var call: BCXCall? {
        didSet {
            if !(self.call==nil) {
                self.call?.removeObserver(observer: self)
            }
            //This statement is needed to subscribe as a call observer. Once we are subscribed, we will be notified anytime the call changes its state.
            self.call?.addObserver(observer: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCallingLabel()
        updateImage()
        updateButtons()
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - View
    //-------------------------------------------------------------------------------------------
    
    private func updateCallingLabel() {
        self.titleLabel?.text = CalleeFormatter.formatCallee(call: self.call)
    }
    
    private func updateButtons() {
    
        if (call?.isIncoming())! && (call?.isRinging())! {
            self.hangUpButton?.isHidden = true
            self.buttonsContainer?.isHidden = false
        } else {
            self.hangUpButton?.isHidden = false
            self.buttonsContainer?.isHidden = true
        }
    }
    
    private func updateImage() {
        
        var image: UIImage?
        if((call?.participants.callees.count)!>1) {
            self.profileImageView?.contentMode = UIViewContentMode.center
            image = UIImage(named: "baseline_group_black_48pt")
        } else {
            self.profileImageView?.contentMode = UIViewContentMode.scaleAspectFit
            image = UIImage(named: "beautiful-blur-blurred-background-733872")
        }
        self.profileImageView?.image = image
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------------------------
    
    @IBAction func answerButtonTouched(_ sender: UIButton) {
        
        //We disable the user interaction because answering a call is an asynchronous process.
        self.view.isUserInteractionEnabled = false
        
        //Then we answer the call. The sdk will take care of notifying the other participants about our intent.
        call?.answer()
        
    }
    
    @IBAction func declineButtonTouched(_ sender: UIButton) {
        
        //We disable the user interaction because declining a call is an asynchronous process.
        self.view.isUserInteractionEnabled = false
        
        //Then we decline the call. The sdk will take care of notifying the other participants about our intent.
        call?.decline()
        
    }
    
    @IBAction func hangUpButtonTouched(_ sender: UIButton) {
        
        //We disable the user interaction because hanging up a call is an asynchronous process.
        self.view.isUserInteractionEnabled = false
        
        //Then we hang up the call. When the call has switched to ended state, we will be notified in the call observer.
        call?.hangUp()
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Call observer
    //-------------------------------------------------------------------------------------------
    
    func callDidConnect(_ call: BCXCall) {
        
        //When the call has been connected, we can proceed to enter the virtual room where the call will take place.
        self.view.isUserInteractionEnabled = true
        showRoomInterface()

    }
    
    func callDidEnd(_ call: BCXCall) {
        
        //When the call ends, we notify our delegate that we have finished our job and we want to be dismissed.
        self.delegate?.callControllerDidEnd(controller: self)

    }
    
    func call(_ call: BCXCall, didChange state: BCXCallState) {
        
        //When the call changes its state, we update the buttons at the bottom of the screen in order to hide answer and
        //decline buttons (if we are handling an incoming call), and we show an hangup button.

        self.updateButtons()

    }
    
    func call(_ call: BCXCall, didFailWithError error: Error) {
        
        //When the call fails, you are notified about the call failure and an error will be provided.
        //Here you could show an alert or a view / viewcontroller to notify the user, that an error occurred and
        //the call has been terminated.
        //Here, for simplicity reason, we notify our delegate that we want to be dismissed.
        let alertController = UIAlertController(title: "Error", message: "Call failed", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:{(UIAlertAction) -> Void in
            self.delegate?.callControllerDidEnd(controller: self)
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {() -> Void in }

    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Navigation
    //-------------------------------------------------------------------------------------------
    
    func showRoomInterface() {
        
        if self.presentedViewController==nil {
            performSegue(withIdentifier: "showRoomSegueId", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier=="showRoomSegueId") {
            let controller = (segue.destination as! RoomViewController)
            controller.call = BandyerCommunicationCenter.instance().callClient.ongoingCall!
        }
        
    }

}
