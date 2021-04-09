//
//  OXANativeAdConfiguration+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenXApolloSDK/OXANativeAdConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdConfiguration()

@property (nonatomic, copy, nullable, readwrite) NSString *version;

@property (nonatomic, strong, nullable) NSNumber *plcmtcnt;
@property (nonatomic, strong, nullable) NSNumber *aurlsupport;
@property (nonatomic, strong, nullable) NSNumber *durlsupport;

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
