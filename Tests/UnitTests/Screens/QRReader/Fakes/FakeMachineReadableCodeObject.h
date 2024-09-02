// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FakeMachineReadableCodeObject : AVMetadataMachineReadableCodeObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) AVMetadataObjectType dataType;

+ (instancetype)createFakeWithCode:(NSString *)code type:(AVMetadataObjectType)type;

@end

NS_ASSUME_NONNULL_END
