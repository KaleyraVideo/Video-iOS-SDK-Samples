// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation

public protocol PropertyProxyProvider {
    typealias Proxy<T> = AnyPropertyProxy<Self, T>
}

extension NSObject: PropertyProxyProvider {}

@propertyWrapper
public struct AnyPropertyProxy<EnclosingType, Value> {

    public typealias ValueKeyPath = ReferenceWritableKeyPath<EnclosingType, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>

    private let keyPath: ValueKeyPath

    public init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }

    @available(*, unavailable, message: "Property proxy can applied to classes only")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    public static subscript(_enclosingInstance instance: EnclosingType,
                            wrapped wrappedKeyPath: ValueKeyPath,
                            storage storageKeyPath: SelfKeyPath
    ) -> Value {
        get {
            instance[keyPath: instance[keyPath: storageKeyPath].keyPath]
        }
        set {
            instance[keyPath: instance[keyPath: storageKeyPath].keyPath] = newValue
        }
    }
}
