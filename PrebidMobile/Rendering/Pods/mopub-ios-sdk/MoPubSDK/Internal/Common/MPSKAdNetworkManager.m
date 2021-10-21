//
//  MPSKAdNetworkManager.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSKAdNetworkManager.h"
// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif
#import "MPAdServerKeys.h"
#import "MPAdServerURLBuilder.h"
#import "MPError.h"
#import "MPHTTPNetworkSession.h"
#import "MPURL.h"
#import "MPURLRequest.h"

#pragma mark UserDefaults Keys

NSString *const kLastSyncTimestampStorageKey  = @"com.mopub.mopub-ios-sdk.skadnetwork.last.sync.timestamp.epoch.seconds";
NSString *const kLastSyncAppVersionStorageKey = @"com.mopub.mopub-ios-sdk.skadnetwork.last.sync.app.version";
NSString *const kLastSyncHashStorageKey       = @"com.mopub.mopub-ios-sdk.skadnetwork.last.sync.hash";

#pragma mark Info.plist Keys

NSString *const kSKAdNetworkItemsInfoPlistKey      = @"SKAdNetworkItems";
NSString *const kSKAdNetworkIdentifierInfoPlistKey = @"SKAdNetworkIdentifier";

#pragma mark Implementation

@interface MPSKAdNetworkManager ()

@property (nonatomic, strong, readonly) NSArray <NSString *> *supportedSkAdNetworks;

@end

@implementation MPSKAdNetworkManager

+ (instancetype)sharedManager {
    static MPSKAdNetworkManager *sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (BOOL)isSkAdNetworkEnabledForApp {
    // SKAdNetwork is only enabled on iOS 14+ when one or more SKAdNetwork IDs is present.
    if (@available(iOS 14.0, *)) {
        return self.supportedSkAdNetworks.count > 0;
    }

    // Otherwise, it is not enabled.
    return NO;
}

- (void)synchronizeSupportedNetworks:(void (^)(NSError *error))completion {
    // Do not attempt to send if SKAdNetwork is not enabled
    if (!self.isSkAdNetworkEnabledForApp) {
        if (completion != nil) { completion(nil); }
        return;
    }

    // Generate the request.
    MPURL *syncUrl = [MPAdServerURLBuilder skAdNetworkSynchronizationURLWithSkAdNetworkIds:self.supportedSkAdNetworks];
    if (syncUrl == nil) {
        if (completion != nil) { completion(nil); }
        return;
    }

    MPURLRequest *syncRequest = [MPURLRequest requestWithURL:syncUrl];

    // Send the synchronization request out.
    __typeof__(self) weakSelf = self;
    [MPHTTPNetworkSession startTaskWithHttpRequest:syncRequest responseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {

        [weakSelf parseDataFromSyncResponse:data completion:completion];

    } errorHandler:^(NSError * _Nonnull error) {
        if (completion != nil) { completion(error); }
    }];
}

- (NSString *)lastSyncTimestampEpochSeconds {
    // Send nil to indicate SKAdNetwork is not enabled
    if (!self.isSkAdNetworkEnabledForApp) {
        return nil;
    }

    // If there is no stored value, send 0 to indicate SKAdNetwork is enabled, but not yet synced
    NSString *storedValue = [[NSUserDefaults standardUserDefaults] objectForKey:kLastSyncTimestampStorageKey];
    return storedValue != nil ? storedValue : @"0";
}

- (NSString *)lastSyncAppVersion {
    // Send nil to indicate SKAdNetwork is not enabled
    if (!self.isSkAdNetworkEnabledForApp) {
        return nil;
    }

    // If there is no stored value, send empty-string to indicate SKAdNetwork is enabled, but not yet synced
    NSString *storedValue = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncAppVersionStorageKey];
    return storedValue != nil ? storedValue : @"";
}

- (NSString *)lastSyncHash {
    // Send nil to indicate SKAdNetwork is not enabled
    if (!self.isSkAdNetworkEnabledForApp) {
        return nil;
    }

    // If there is no stored value, send empty-string to indicate SKAdNetwork is enabled, but not yet synced
    NSString *storedValue = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSyncHashStorageKey];
    return storedValue != nil ? storedValue : @"";
}

#pragma mark Helper Methods

- (void)parseDataFromSyncResponse:(NSData *)data completion:(void (^)(NSError *error))completion {
    NSError *parseError;
    NSDictionary<NSString *, NSString *> *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

    // Validate the data:
    // if dictionary is nil, return JSON parse error
    if (responseDictionary == nil) {
        if (completion != nil) { completion(parseError); }
        return;
    }
    // if dictionary isn't a dictionary as expected, return our error
    if (![responseDictionary isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithCode:MOPUBErrorUnableToParseJSONAdResponse];
        if (completion != nil) { completion(error); }
        return;
    }
    // if hash is nil or not a string, return our error
    NSString *hash = responseDictionary[kSKAdNetworkHashKey];
    if (hash == nil || ![hash isKindOfClass:[NSString class]] || hash.length == 0) {
        NSError *error = [NSError errorWithCode:MOPUBErrorUnableToParseJSONAdResponse];
        if (completion != nil) { completion(error); }
        return;
    }

    // Hash is valid; save in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:hash forKey:kLastSyncHashStorageKey];

    // Save metadata associated with the hash:
    // App version
    [[NSUserDefaults standardUserDefaults] setObject:MPDeviceInformation.applicationVersion
                                              forKey:kLastSyncAppVersionStorageKey];
    // Timestamp
    NSUInteger nowEpochSeconds = (NSUInteger)[[NSDate date] timeIntervalSince1970];
    NSString *nowEpochSecondsString = [NSString stringWithFormat:@"%@", @(nowEpochSeconds)];
    [[NSUserDefaults standardUserDefaults] setObject:nowEpochSecondsString
                                              forKey:kLastSyncTimestampStorageKey];

    // Done!
    if (completion != nil) { completion(nil); }
}

- (NSArray<NSString *> *)supportedSkAdNetworks {
    // Since this value is gathered from the Info.plist, it will not change during the lifetime of the app.
    // Generate once and always use.
    static NSArray<NSString *> *sSupportedNetworks = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *skAdNetworkItemsArray = [NSBundle mainBundle].infoDictionary[kSKAdNetworkItemsInfoPlistKey];

        // Validate that this is non-nil and an array. If not, supportedNetworks will stay @c nil.
        if (skAdNetworkItemsArray == nil || ![skAdNetworkItemsArray isKindOfClass:[NSArray class]]) {
            return;
        }

        // Use a set to keep track of the list of SKAdNetworks. This ensures that the list the
        // SDK keeps track of is de-duplicated.
        NSMutableSet *networkIdentifiers = [NSMutableSet setWithCapacity:skAdNetworkItemsArray.count];

        // Transform dictionary entries into strings, and add into @c networkIdentifiers set
        for (NSDictionary *item in skAdNetworkItemsArray) {
            NSString *networkIdentifier = item[kSKAdNetworkIdentifierInfoPlistKey];

            // Validate that the network identifier is non-nil and a string
            if (networkIdentifier == nil || ![networkIdentifier isKindOfClass:[NSString class]]) {
                continue;
            }

            // Add network identifier to set
            [networkIdentifiers addObject:networkIdentifier];
        }

        sSupportedNetworks = networkIdentifiers.count > 0 ? [networkIdentifiers allObjects] : nil;
    });

    return sSupportedNetworks;
}

@end
