// Copyright © 2018 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information

import UIKit
import BandyerCoreAV

class StreamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoView: BAVVideoView?
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.videoView?.stopRendering()
        
    }
    
}
