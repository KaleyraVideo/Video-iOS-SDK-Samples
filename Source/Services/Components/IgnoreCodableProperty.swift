// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

@propertyWrapper
struct IgnoreCodableProperty<Value>: Codable {

    private var value: Value?

    init(wrappedValue: Value?) {
        self.value = wrappedValue
    }

    var wrappedValue: Value? {
        get {
            value
        }
        set {
            self.value = newValue
        }
    }

    func encode(to encoder: Encoder) throws {}

    init(from decoder: Decoder) throws {
        self.value = nil
    }
}
