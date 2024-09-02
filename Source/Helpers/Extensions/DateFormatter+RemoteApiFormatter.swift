// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

extension DateFormatter {

    static let remoteApiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .UTC
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
}

extension TimeZone {

    static let UTC: TimeZone! = TimeZone(abbreviation: "UTC")
}
