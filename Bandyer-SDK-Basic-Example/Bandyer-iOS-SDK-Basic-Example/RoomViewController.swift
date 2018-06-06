// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCommunicationCenter
import BandyerCoreAV

class RoomViewController: UIViewController, BAVRoomObserver, BAVPublisherObserver {
    
    #if arch(i386) || arch(x86_64)
    var capturer: BAVVideoCapturer?
    #else
    var capturer: BAVCameraCapturer?
    #endif
    
    @IBOutlet var overlayGestureRecognizer: UITapGestureRecognizer?
    
    var overlayAutoDismissTimer: Timer?
    
    var publisher: BAVPublisher?
    
    var localVideoView: UIView?
    
    var fullScreenTopConstraint: NSLayoutConstraint?
    var fullScreenLeftConstraint: NSLayoutConstraint?
    var fullScreenRightConstraint: NSLayoutConstraint?
    var fullScreenBottomConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    var isExpanded: Bool = true
    
    var room: BAVRoom? {
        didSet {
            self.room?.addObserver(observer: self)
        }
    }
    var call: BCXCall? {
        didSet {
            self.room = self.call?.room
        }
    }
    
    weak var streamsController: StreamsCollectionViewController?
    weak var callControlsController: CallControlsViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //This view controller will take care of handling the actual video call process.
        //The steps taken so far, were needed to contact the other participants and manage the call signaling. From this moment on, the actual
        //call can begin and we can start talking and seeing the other participants.
        
        //Please note, that you must add an NSCameraUsageDescription and an NSMicrophoneUsageDescription keys to your app's Info.plist, otherwise
        //on devices with iOS 10.0 or above installed, the app will crash as soon as the sdk tries to access the camera or the microphone.
        //Please also note that you must take care of camera and microphone permissions. If the user doesn't grant or revokes the permission
        //to access one of those two resources, the sdk will not complain and local video or audio streams will not be sent to the remote parties.
        //So you must check that the user has granted camera and microphone permissions before joining a room.
        
        setupAudioSession()
        setupCapturer()
        setupVideoPreview()
        
        addStreamsController()
        addOverlayController()
        
    }
    
    private func setupAudioSession() {
        
        //One of the first thing to do is setup the audio session, specifying the settings we want to use.
        //If we use the default settings, as in this case, the following statements could be skipped altogether.
        //If you don't setup an audio session, one will be setup automatically for you, with the default configuration and it will be started
        //automatically when needed.
        
        BAVAudioSession.instance().notificationQueue = DispatchQueue.main
        BAVAudioSession.instance().useManualAudio = false
        BAVAudioSession.instance().configure({(_ configuration: BAVAudioSessionConfiguration?) -> Void in })
        
    }
    
    private func setupCapturer() {
        
        //In the next step, we setup a capturer for a video source.
        #if arch(i386) || arch(x86_64)
        //The simulator doesn't provide camera support, so we must use a fake capturer that captures video frames from a video file.
        self.capturer = BAVFileVideoCapturer(fileNamed: "SampleVideo_640x360_10mb", withExtension: "mp4", in: Bundle.main)
        #else
        //If we run the application on a real device, we have camera support, so we setup a camera capturer specifying the starting camera position
        //and a capture format. Although, you can use the default camera capture format and position.
        //Please note, that you must add an NSCameraUsageDescription key in you app's Info.plist. From iOS 10.0 and above this key is needed to access
        //the device camera, failing to do so will crash the app.
        //Once started, the system will prompt the user with a system alert asking the permission to use the camera.
        //Please note that the sdk will NOT take care of denied permissions, that is, in case of camera permissions denied, black frames will be
        //sent to other participants. You must take care of camera and microphone permissions before starting a call or before joining a room.
        let position: AVCaptureDevice.Position = AVCaptureDevice.Position.front
        let videoFormat: BAVVideoFormat? = BAVVideoFormat.default()
        self.capturer = BAVCameraCapturer(cameraPosition: position, videoFormat: videoFormat!)
        #endif
        
        self.capturer?.start()
        
    }
    
    private func setupVideoPreview() {
        
        //In order to see our camera feed we must add a camera preview view to our view hierarchy.
        var view: UIView?
        #if arch(i386) || arch(x86_64)
        //If we run the app on the simulator we cannot use the camera capturer, and as a result we cannot use the camera preview view
        //so a video view must be created instead.
        //As a side note, this view will render the frame that will be sent to the other participants.
        view = BAVVideoView(frame:  CGRect.zero)
        #else
        //The camera preview view will render the local camera feed.
        view = BAVCameraPreviewView(frame:  CGRect.zero)
        
        //Don't forget to set the capture session on the view, otherwise nothing will be rendered.
        (view as! BAVCameraPreviewView).captureSession = capturer?.captureSession
        #endif
        
        self.localVideoView = view
        self.localVideoView?.backgroundColor = UIColor.clear
        self.localVideoView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view!)
        
        fullScreenTopConstraint = self.localVideoView?.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor)
        fullScreenTopConstraint?.priority = UILayoutPriority.defaultHigh
        fullScreenTopConstraint?.isActive = true
        
        fullScreenLeftConstraint = self.localVideoView?.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        fullScreenLeftConstraint?.priority = UILayoutPriority.defaultHigh
        fullScreenLeftConstraint?.isActive = true
        
        fullScreenRightConstraint = self.localVideoView?.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        fullScreenRightConstraint?.priority = UILayoutPriority.defaultHigh
        fullScreenRightConstraint?.isActive = true
        
        fullScreenBottomConstraint = self.localVideoView?.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
        fullScreenBottomConstraint?.priority = UILayoutPriority.defaultHigh
        fullScreenBottomConstraint?.isActive = true
        
        widthConstraint = self.localVideoView?.widthAnchor.constraint(equalToConstant: 120)
        widthConstraint?.priority = UILayoutPriority.defaultHigh
        widthConstraint?.isActive = false
        heightConstraint = self.localVideoView?.heightAnchor.constraint(equalToConstant: 120)
        heightConstraint?.priority = UILayoutPriority.defaultHigh
        heightConstraint?.isActive = false
        
    }
    
    private func addStreamsController() {
        
        //Here we are using view controller containment to add a collection view controller that will take care of showing remotes participants
        //video feeds.
        let streamsViewController = self.storyboard?.instantiateViewController(withIdentifier: "streamsController") as? StreamsCollectionViewController
        
        streamsViewController?.room = self.room
        
        self.addChildViewController(streamsViewController!)
        streamsViewController!.view.frame = self.view.bounds
        streamsViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(streamsViewController!.view)
        streamsViewController!.didMove(toParentViewController: self)
        
        self.streamsController = streamsViewController
        
    }
    
    private func addOverlayController() {
        
        //Here we are using view controller containment to add an overlay view controller that will the interaction with the user.
        let callControlsViewController = self.storyboard?.instantiateViewController(withIdentifier: "controlsController") as? CallControlsViewController
        
        callControlsViewController?.call = self.call
        
        self.addChildViewController(callControlsViewController!)
        callControlsViewController!.view.frame = self.view.bounds
        callControlsViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(callControlsViewController!.view)
        callControlsViewController!.didMove(toParentViewController: self)
        
        self.callControlsController = callControlsViewController

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        //Once the view is going to appear on screen, we will start joining the virtual room. This must be done only once.
        if self.room?.state != BAVRoomState.connected {
            self.room?.join()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.startOverlayAutoDismissTimer()
        
    }
    
    deinit  {
        
        //Don't forget to stop the capturer, once the view controller is not needed anymore.
        self.capturer?.stop()
        self.stopOverlayAutoDismissTimer()
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Layout
    //-------------------------------------------------------------------------------------------
    
    private func resizeLocalPreview(isExpanded: Bool) {
        
        self.isExpanded = isExpanded
        
        if isExpanded {
            
            updateConstraintsForPreviewInFullScreen()
            
        } else {
            
            updateConstraintsForPreviewAsThumbnail()
            
        }
        
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        
        self.view.bringSubview(toFront: self.localVideoView!)
        
    }
    
    private func updateConstraintsForPreviewInFullScreen() {
        
        fullScreenRightConstraint?.constant = 0
        fullScreenBottomConstraint?.constant = 0
        
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        
        fullScreenTopConstraint?.isActive = true
        fullScreenRightConstraint?.isActive = true
        fullScreenLeftConstraint?.isActive = true
        fullScreenBottomConstraint?.isActive = true
        
    }
    
    private func updateConstraintsForPreviewAsThumbnail() {
        
        fullScreenRightConstraint?.constant = -25
        fullScreenBottomConstraint?.constant = -90
        
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
        
        fullScreenTopConstraint?.isActive = false
        fullScreenRightConstraint?.isActive = true
        fullScreenLeftConstraint?.isActive = false
        fullScreenBottomConstraint?.isActive = true
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Room Observer
    //-------------------------------------------------------------------------------------------
    
    func roomDidConnect(_ room: BAVRoom) {
        
        publish(BAVPublisher(), withOptions: BAVPublishOptions.init())
        
    }
    
    private func publish(_ publisher: BAVPublisher?, withOptions options: BAVPublishOptions) {
        
        //When the room is successfully connected, we are ready to publish our audio and video streams.
        //We create a publisher that is responsible for interacting with the room.
        //The publisher will take care of streaming our video and audio feeds to the other participants in the room.
        self.publisher = publisher
        publisher?.publishOptions = options
        publisher?.capturer = self.capturer
        publisher?.user = BandyerCommunicationCenter.instance().callClient.user
        publisher?.addObserver(observer: self)
        
        //Once a publisher has been setup, we must publish its stream in the room.
        //Publishing is an asynchronous process. If something goes wrong while starting the publish process, an error will
        //be reported in the error handler below synchronously. Otherwise if the publish process can be started, any error occurred will be reported
        //to the observers registered on the publisher object.
        var error: NSError? = nil
        self.room?.publish(publisher!, error: &error)
        if let errorPointer = error {
            let alertController = UIAlertController(title: "Room publish Failed", message: errorPointer.localizedDescription, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {() -> Void in }
            
        }
        
    }
    
    func roomDidDisconnect(_ room: BAVRoom) {
        //When the room disconnects this method will be invoked on any room observer.
        //Here, we do nothing because the call will fail and the call view controller (and in turn this view controller) will be dismissed.
        //If your navigation flow is different you could for example prompt an error message to the user.
    }
    
    func room(_ room: BAVRoom, didFailWithError error: Error) {
        //When the room detects a fatal error, this method will be invoked on any room observer.
        //Here, we do nothing because the call will fail and the call view controller (and in turn this view controller) will be dismissed.
    }
    
    func room(_ room: BAVRoom, didAdd stream: BAVStream) {
        
        //When a new stream is added to the room this method will be invoked. Here we have the chance to subscribe to the stream just added.
        
        //First we check that the stream added is not our local stream, if so we ignore it because we cannot subscribe to our local stream.
        if(self.publisher?.stream?.streamId != stream.streamId) {
            
            resizeLocalPreview(isExpanded: false)

            //If a remote stream is added to the room we subscribe to it, creating a subscriber object that is responsible for handling the process
            //of subscribing to the remote audio and video feeds.
            let subscriber: BAVSubscriber = BAVSubscriber.init(stream: stream)
            
            //Once a subscriber has been setup, we signal the room we are ready to subscribe to the remote stream.
            //Subscribing to a remote stream is an asynchronous process. If something goes wrong while starting the subscribe process an error will be
            //reported in the error handler below. Otherwise, the subscribing process is started and any error occurring from this moment on
            //will be reported to the observers registered on the observer object.
            var error: NSError? = nil
            self.room?.subscribe(subscriber, error: &error)
            if let errorPointer = error {
                let alertController = UIAlertController(title: "Stream subscribe Failed", message: errorPointer.localizedDescription, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: true) {() -> Void in }
            }
            
        }
        
    }
    
    func room(_ room: BAVRoom, didRemove stream: BAVStream) {

        //When a stream is removed from the room, this method will be invoked. Here you have the chance to update your user interface or perform
        //other tasks
        
        //Here, for example, we update our local preview showing it in fullscreen.
        if(room.subscribers.count == 0) {
            resizeLocalPreview(isExpanded: true)
        }
        
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - Publisher Observer
    //-------------------------------------------------------------------------------------------

    func publisherDidCreateStream(_ publisher: BAVPublisher) {
        
        //When the publisher has created its stream, this method will be invoked.
        //Here we are adding the stream to the local preview view in order to render it. We do it only on simulator because on a real device
        //the camera feed is available as soon as the capture session starts.
        #if arch(i386) || arch(x86_64)
        (localVideoView as! BAVVideoView).stream = publisher.stream!
        (localVideoView as! BAVVideoView).startRendering()
        resizeLocalPreview(isExpanded: self.isExpanded)
        #endif
        
    }
    
    func publisher(_ publisher: BAVPublisher, didFailWithError error: Error) {
        
        let alertController = UIAlertController(title: "Publisher Failed", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true) {() -> Void in }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------------------------
    
    @IBAction func overlayGestureRecognizerTapped(uiGestureRecognizer: UIGestureRecognizer) {
        
        if callControlsController!.isViewLoaded && callControlsController!.view.isHidden {
            if (callControlsController?.view.isHidden)! {
                showOverlay()
                startOverlayAutoDismissTimer()
            } else {
                hideOverlay()
                stopOverlayAutoDismissTimer()
            }
        }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Overlay
    //-------------------------------------------------------------------------------------------
    
    private func startOverlayAutoDismissTimer() {
        
        overlayAutoDismissTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.overlayDismissalTimerFired(_:)), userInfo: nil, repeats: false)
        
    }
    
    private func stopOverlayAutoDismissTimer() {
        
        overlayAutoDismissTimer?.invalidate()
        overlayAutoDismissTimer = nil
        
    }
    @objc private func overlayDismissalTimerFired(_ timer: Timer?) {
        
        hideOverlay()
        
    }
    private func showOverlay() {
        
        if callControlsController != nil {
            view.bringSubview(toFront: (callControlsController?.view!)!)
            callControlsController?.view.isHidden = false
        }
        
    }
    private func hideOverlay() {
        
        if callControlsController != nil {
            view.sendSubview(toBack: (callControlsController?.view!)!)
            callControlsController?.view.isHidden = true
        }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Status Bar Style
    //-------------------------------------------------------------------------------------------
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
}
