// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#import "FakeMachineReadableCodeObject.h"

@implementation FakeMachineReadableCodeObject

- (NSString *)stringValue
{
    return self.code;
}

- (AVMetadataObjectType)type
{
    return self.dataType;
}

- (instancetype)initWithCode:(NSString *)code type:(AVMetadataObjectType)type
{
    _code = code;
    _dataType = type;

    return self;
}

+ (instancetype)createFakeWithCode:(NSString *)code type:(AVMetadataObjectType)type
{    
    return [[FakeMachineReadableCodeObject alloc] initWithCode:code type:type];
}

@end
