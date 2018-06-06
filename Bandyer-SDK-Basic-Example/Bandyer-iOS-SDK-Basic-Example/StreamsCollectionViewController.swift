// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCoreAV

private let reuseIdentifier = "remoteCell"

class StreamsCollectionViewController: UICollectionViewController, BAVRoomObserver, BAVSubscriberObserver, UICollectionViewDelegateFlowLayout {
    
    var room: BAVRoom? {
        didSet {
            room?.addObserver(observer: self)
        }
    }

    //-------------------------------------------------------------------------------------------
    // MARK: - View
    //-------------------------------------------------------------------------------------------

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //This view controller is responsible for showing the remote video feeds of the other participants publishing their streams in this room.
        self.collectionView!.register(UINib.init(nibName: "StreamCollectionViewCell",bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: reuseIdentifier)
    
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - UICollectionViewDataSource
    //-------------------------------------------------------------------------------------------

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.room?.subscribers.count)!
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StreamCollectionViewCell
        #if !TARGET_INTERFACE_BUILDER
        cell.videoView?.videoSizeFittingMode = BAVVideoSizeFittingMode.aspectFillMode
        #endif
        cell.videoView?.stream = (self.room?.subscribers[indexPath.row].stream)!
        cell.videoView?.startRendering()
        return cell
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - UICollectionViewDelegate
    //-------------------------------------------------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if room?.subscribers.count == 1 {
            return collectionView.frame.size
        } else if room?.subscribers.count == 2 {
            if collectionView.bounds.size.width < collectionView.bounds.size.height {
                return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height / 2)
            } else {
                return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height)
            }
        } else {
            return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height / 2)
        }
        
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - Room Observer
    //-------------------------------------------------------------------------------------------

    func roomDidConnect(_ room: BAVRoom) {
    }
    
    func roomDidDisconnect(_ room: BAVRoom) {
    }
    
    func room(_ room: BAVRoom, didFailWithError error: Error) {
    }
    
    func room(_ room: BAVRoom, didAdd stream: BAVStream) {
    }
    
    func room(_ room: BAVRoom, didRemove stream: BAVStream) {
        
        self.collectionView?.reloadData()
    
    }
    
    func room(_ room: BAVRoom, didAdd subscriber: BAVSubscriber) {
        
        //When a new subscriber is added to the room we update our collection view
        //(we are adding a new subscriber any time a new remote stream is added to the room in the RoomViewController).
        self.collectionView?.reloadData()
    
        subscriber.addObserver(observer: self)
        
    }
    
    func room(_ room: BAVRoom, didRemove subscriber: BAVSubscriber) {
        
        //When a subscriber is removed from the room we update our collection view.
        self.collectionView?.reloadData()
        
        subscriber.removeObserver(observer: self)
    
    }
    
    func subscriberDidConnect(toStream subscriber: BAVSubscriber) {
        
        //Once the subscriber has connected to its stream successfully, we update the cell that is showing the remote video feed, starting the rendering process.
        let index = room?.subscribers.index(of: subscriber)
        let cell = self.collectionView?.cellForItem(at: IndexPath.init(item: index!, section: 0)) as? StreamCollectionViewCell
        cell?.videoView?.startRendering()
        
    }
    
    func subscriberDidDisconnect(fromStream subscriber: BAVSubscriber) {
        
        //Once the subscriber has disconnected from its stream, we update the cell that is showing the remote video feed, stopping the rendering process.
        let index = room?.subscribers.index(of: subscriber)
        let cell = self.collectionView?.cellForItem(at: IndexPath.init(item: index!, section: 0)) as? StreamCollectionViewCell
        cell?.videoView?.stopRendering()
        
    }
    
    func subscriber(_ subscriber: BAVSubscriber, didFailWithError error: Error) {
        //Here, you have the chance to update your view showing an error message on a cell or prompt an alert to the user.
    }
    
}
