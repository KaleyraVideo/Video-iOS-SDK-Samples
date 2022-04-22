//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation

struct Constants {

    #error("Please change these constants with you own values")

    // The app id identifies your company in the Kaleyra video ecosystem
    static let AppId = "PUT YOUR APP ID HERE"

    // When integrating the SDK in your app you are not required to provide an api key
    // We are using the api key in this app only to retrieve the user list for your company
    // for simplicity and demonstration purpose only
    static let ApiKey = "PUT YOUR API KEY HERE"

    // A URL pointing to a REST API on your backend where retrieve users informations.
    static let RestURL = "REST URL"

    // The App group identifier is needed by the SDK and the BroadcastExtension in order to communicate
    // If you plan to not opt-in for the Broadcast screen sharing feature you can leave this field as is
    static let AppGroupIdentifier = "PUT THE APP GROUP IDENTIFIER HERE"

    // The broadcast upload app extension bundle identifier is needed by the SDK and in order to tell
    // the system picker to list only your broadcast upload extension among those that are installed on the
    // device capable of handling a broadcast upload.
    // If you plan to not opt-in for the Broadcast screen sharing feature you can leave this field as is
    static let BroadcastExtensionBundleId = "PUT THE BROADCAST EXTENSION BUNDLE ID HERE"
}
