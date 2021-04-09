//
//  MPSKAdNetworkManager.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPSKAdNetworkManager : NSObject

/**
 The shared instance of @c MPSKAdNetworkManager
 */
+ (instancetype)sharedManager;

/**
 Indicates whether SKAdNetwork is enabled for this app. Returns @c YES if the Info.plist
 contains at least one SKAdNetwork ID; returns @c NO otherwise.
 */
@property (nonatomic, readonly, assign) BOOL isSkAdNetworkEnabledForApp;

/**
 Synchronizes the SKAdNetwork list to ad server, and writes hash (alongside timestamp
 and present app version) to disk upon successful sync.

 If sync failed, the @c error parameter in the @c completion block will be non-nil,
 and no values will be written to disk.

 @param completion called upon completion of sync. @c error will be non-nil if sync failed,
 otherwise the sync succeeded.
 */
- (void)synchronizeSupportedNetworks:(void (^ _Nullable)(NSError * _Nullable error))completion;

/**
 The hash value given by ad server upon the last successful sync.
 */
@property (nonatomic, readonly, copy, nullable) NSString *lastSyncHash;

/**
 The timestamp of the last successful sync in epoch time seconds, converted to string.
 */
@property (nonatomic, readonly, copy, nullable) NSString *lastSyncTimestampEpochSeconds;

/**
 The app version when the last successful sync occurred.
 */
@property (nonatomic, readonly, copy, nullable) NSString *lastSyncAppVersion;

@end

NS_ASSUME_NONNULL_END
