// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import ReplayKit
#if canImport(KaleyraVideoBroadcastExtension)
import KaleyraVideoBroadcastExtension
#elseif canImport(BandyerBroadcastExtension)
import BandyerBroadcastExtension
#endif

final class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        guard #available(iOS 15.0, *) else { return }
#if canImport(KaleyraVideoBroadcastExtension)
        BroadcastExtension.logLevel = .all
#endif
        do {
            BroadcastExtension.instance.start(appGroupIdentifier: try .init("group.com.bandyer.BandyerSDKSample"),
                                              setupInfo: nil) { [unowned self] error in
                self.perform(#selector(finishBroadcastWithError(_:)), with: error)
            }
        } catch {
            finishBroadcastWithError(error)
        }
    }

    override func broadcastPaused() {
        guard #available(iOS 15.0, *) else { return }
        BroadcastExtension.instance.pause()
    }

    override func broadcastResumed() {
        guard #available(iOS 15.0, *) else { return }
        BroadcastExtension.instance.resume()
    }

    override func broadcastFinished() {
        guard #available(iOS 15.0, *) else { return }
        BroadcastExtension.instance.finish()
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard #available(iOS 15.0, *) else { return }
        BroadcastExtension.instance.process(sampleBuffer: sampleBuffer, ofType: sampleBufferType)
    }
}
