// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#import "FakeAVCaptureOutputCodeObject.h"

@implementation FakeAVCaptureOutputCodeObject

- (instancetype)initWithDummy:(NSString *)dummy
{
    return self;
}

+ (instancetype)createFake
{
    return [[FakeAVCaptureOutputCodeObject alloc] initWithDummy:@""];
}

@end
