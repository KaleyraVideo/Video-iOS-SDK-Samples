// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCommunicationCenter
import BandyerCoreAV

class CallControlsViewController: UIViewController, BCXCallObserver, BAVRoomObserver, BAVPublisherObserver,  BAVAudioSessionObserver {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var micButton: UIButton?
    @IBOutlet weak var hangUpButton: UIButton?
    @IBOutlet weak var switchCameraButton: UIButton?
    @IBOutlet weak var videoButton: UIButton?
    @IBOutlet weak var speakerButton: UIButton?
    
    var micEnabled = true
    var videoEnabled = true
    
    var canOverrideAudioOutput = false
    var isOverridingAudioOutput = false
    var isOverridingAudioOnSpeaker = false
    
    var call: BCXCall? {
        didSet {
            call?.addObserver(observer: self)
            call?.room?.addObserver(observer: self)
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - View
    //-------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        //This view controller is responsible for handling the user interaction with the user.
        //The user can interact with the controls provided by this view controller, for switching between the front and back cameras (if present),
        //muting/unmuting the microphone, enabling/disabling the local video stream, changing the audio output device.

        BAVAudioSession.instance().addObserver(observer: self)

        #if !arch(i386) && !arch(x86_64)
        //iOS audio session is a bit tricky. When the user wants to override the audio output from
        //the built-in receiver (earpiece) to the loud speaker, we must change the audio output route on the audio session.
        //To do it so we must call "overrideAudioOutputPort(_ override: AVAudioSessionPortOverride)" method on the audio session singleton instance specifying "AVAudioSessionPortOverride.none"
        //as method argument if we want route the audio output to the built-in receiver, or "AVAudioSessionPortOverride.speaker" as method argument
        //if we want route the audio output to the loud speaker. However, only iPhone devices have support for a built-in receiver,
        //on iPads and on Simulators there is not such a device.
        //To make things easy, we allow changing the audio route only on iPhone devices.
        self.canOverrideAudioOutput = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        #endif
        
        updateCalleeLabel()
        updateButtons()
        
    }
    
    private func updateCalleeLabel() {
        
        self.titleLabel?.text = CalleeFormatter.formatCallee(call: self.call)

    }
    
    private func updateButtons() {
        
        updateSwitchCameraButton()
        updateMicButton()
        updateVideoButton()
        updateSpeakerButton()
        
    }
    
    private func updateSwitchCameraButton() {

        //On simulators, camera support is missing, so we disable the switch camera button altogether.
        #if arch(i386) || arch(x86_64)
        self.switchCameraButton?.isEnabled = false
        #endif
        
    }
    
    private func updateMicButton() {
        
        let localStream = self.call?.room?.publisher?.stream
        let image = (localStream != nil && (localStream?.hasAudioEnabled)!) ? UIImage.init(named: "baseline_mic_off_white_24pt") : UIImage.init(named: "baseline_mic_white_24pt")
        self.micButton?.setImage(image, for: UIControlState.normal)
        
    }
    
    private func updateVideoButton() {
        
        let localStream = self.call?.room?.publisher?.stream
        let image = (localStream != nil && (localStream?.hasVideoEnabled)!) ? UIImage.init(named: "baseline_videocam_off_white_24pt") : UIImage.init(named: "baseline_videocam_white_24pt")
        self.videoButton?.setImage(image, for: UIControlState.normal)
        
    }
    
    private func updateSpeakerButton() {
        
        let image = self.isOverridingAudioOnSpeaker ? UIImage.init(named: "baseline_volume_up_white_24pt") : UIImage.init(named: "baseline_speaker_phone_white_24pt")
        self.speakerButton?.setImage(image, for: UIControlState.normal)
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------------------------
    
    @IBAction func switchCameraButtonTouched(_ sender: UIButton) {

        //Please note that changing the camera position is NOT a synchronous process, it takes some time because the camera capture session
        //must be stopped, updated and restarted. All of these operations are executed on background queue asynchronously.
        //So you should disable the switch camera button for a while, in order to prevent the user from tapping on it when the camera capture session
        //is still restarting.
        #if !arch(i386) && !arch(x86_64)
        (self.call?.room?.publisher?.capturer as! BAVCameraCapturer).toggleCameraPosition()
        #endif
        
    }
    
    @IBAction func micButtonTouched(_ sender: UIButton) {
        
        let stream: BAVStream? =  self.call?.room?.publisher?.stream
        
        //Muting or unmuting the local audio is a pretty straightforward process, you just need to disable or enabled the audio of the publisher's stream.
        if(micEnabled) {
            micEnabled = false
            stream?.disableAudio()
        } else {
            micEnabled = true
            stream?.enableAudio()
        }
        self.updateMicButton()
        
    }
    
    @IBAction func hangUpButtonTouched(_ sender: UIButton) {
        
        call?.hangUp()
        
    }
    
    @IBAction func videoButtonTouched(_ sender: UIButton) {
        
        let stream: BAVStream? =  self.call?.room?.publisher?.stream

        //Disabling or enabling the local video feed is a pretty straightforward process, you just need to disable or enabled the video of the publisher's stream.
        if(videoEnabled) {
            videoEnabled = false
            stream?.disableVideo()
        } else {
            videoEnabled = true
            stream?.enableVideo()
        }
        updateVideoButton()
        
    }
    
    @IBAction func speakerButtonTouched(_ sender: UIButton) {
        
        if canOverrideAudioOutput && !self.isOverridingAudioOutput {

            //Here we override temporarily the current audio output route. This is an asynchronous process and success or
            //failure will be reported in the audio session observer methods below.
            
            self.isOverridingAudioOutput = true
            
            if(self.isOverridingAudioOnSpeaker) {
                BAVAudioSession.instance().overrideAudioOutputPort(AVAudioSessionPortOverride.none)
            } else {
                BAVAudioSession.instance().overrideAudioOutputPort(AVAudioSessionPortOverride.speaker)
            }
            
        }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Audio Session Observer
    //-------------------------------------------------------------------------------------------
    
    func audioSession(_ audioSession: BAVAudioSession, didOverrideOutputPort override: AVAudioSessionPortOverride) {

        //This method is invoked whenever the current audio output route is overridden successfully.
        //Please note that this method will be invoked only when we ask to override the audio output port explicitly on the audio session.
        //When audio route changes for any other reason this method won't be invoked, you must implement "audioSessionDidChangeRoute(_ session:, reason:, previousRoute:)"
        //method if you want to be notified about audio route changes.
        self.isOverridingAudioOnSpeaker = (override == AVAudioSessionPortOverride.speaker)
        updateSpeakerButton()
        self.isOverridingAudioOutput = false
        
    }
    
    func audioSession(_ audioSession: BAVAudioSession, didFailToOverrideOutputPortWithError error: Error) {
        
        //This method is invoked whenever an override of the audio output port has failed.
        self.isOverridingAudioOutput = false
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Room Observer
    //-------------------------------------------------------------------------------------------
    
    func room(_ room: BAVRoom, didAdd publisher: BAVPublisher) {
        
        publisher.addObserver(observer: self)
        
    }
    
    func roomDidConnect(_ room: BAVRoom) {
    }
    
    func roomDidDisconnect(_ room: BAVRoom) {
    }
    
    func room(_ room: BAVRoom, didFailWithError error: Error) {
    }
    
    func room(_ room: BAVRoom, didAdd stream: BAVStream) {
    }
    
    func room(_ room: BAVRoom, didRemove stream: BAVStream) {
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Publisher Observer
    //-------------------------------------------------------------------------------------------
    
    
    func publisher(_ publisher: BAVPublisher, didFailWithError error: Error) {
    }
    
    func publisherDidCreateStream(_ publisher: BAVPublisher) {
        
        updateButtons()
        
    }
   
    
}
