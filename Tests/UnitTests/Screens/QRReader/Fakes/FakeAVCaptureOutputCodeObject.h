// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FakeAVCaptureOutputCodeObject : AVCaptureOutput

+ (instancetype)createFake;

@end

NS_ASSUME_NONNULL_END
