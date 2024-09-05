// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

var appDelegateClass: AnyClass = AppDelegate.self

var delegate: String

if let testingDelegateClass = NSClassFromString("TestingAppDelegate") {
    delegate = NSStringFromClass(testingDelegateClass)
} else {
    delegate = NSStringFromClass(appDelegateClass)
}

// Enable this snippet if you want to redirect sdout and sderr to /dev/null
//let fd = open("/dev/null", O_RDWR)
//assert(fd >= 0)
//var success = dup2(fd, STDOUT_FILENO) >= 0
//assert(success)
//success = dup2(fd, STDERR_FILENO) >= 0
//assert(success)

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegate)
