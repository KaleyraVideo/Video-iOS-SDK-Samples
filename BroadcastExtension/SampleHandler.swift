// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import ReplayKit
#if canImport(KaleyraVideoBroadcastExtension)
import KaleyraVideoBroadcastExtension
#elseif canImport(BandyerBroadcastExtension)
import BandyerBroadcastExtension
#endif

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        guard #available(iOSApplicationExtension 15.0, *) else { return }

        BroadcastExtension.instance.start(appGroupIdentifier: "group.com.bandyer.BandyerSDKSample", setupInfo: nil) { [unowned self] error in
            self.finishBroadcastWithError(error)
        }
    }

    override func broadcastPaused() {
        guard #available(iOSApplicationExtension 15.0, *) else { return }

        BroadcastExtension.instance.pause()
    }

    override func broadcastResumed() {
        guard #available(iOSApplicationExtension 15.0, *) else { return }

        BroadcastExtension.instance.resume()
    }

    override func broadcastFinished() {
        guard #available(iOSApplicationExtension 15.0, *) else { return }

        BroadcastExtension.instance.finish()
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard #available(iOSApplicationExtension 15.0, *) else { return }

        BroadcastExtension.instance.process(sampleBuffer: sampleBuffer, ofType: sampleBufferType)
    }
}
