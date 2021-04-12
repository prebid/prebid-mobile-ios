//
//  MPSKAdNetworkClickthroughData.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Model class to hold SKAdNetwork clickthrough metadata, and also converter from ad server format to
 @c SKStoreProductViewController format.
 */
@interface MPSKAdNetworkClickthroughData : NSObject

#pragma mark Initialization

/**
 The initializer takes in a dictionary parsed from the ad server's JSON. If any data is missing or not able
 to be parsed, the initializer will return @c nil.

 @param dictionary the JSON dictionary parsed into an NSDictionary from ad server.
 @return the @c MPSKAdNetworkClickthroughData instance, or @c nil if data is missing or unable to be parsed.
 */
- (instancetype)initWithDictionary:(NSDictionary <NSString *, NSString *> *)dictionary NS_DESIGNATED_INITIALIZER;

#pragma mark Properties

/**
 The version of the SKAdNetwork API used.
 */
@property (nonatomic, copy, readonly) NSString *version;

/**
 The ad network's unique identifier.
 */
@property (nonatomic, copy, readonly) NSString *networkIdentifier;

/**
 The campaign identifier set by the ad network.
 */
@property (nonatomic, copy, readonly) NSNumber *campaignIdentifier;

/**
 The app store identifier for the app to be shown in the @c SKStoreProductViewController.
 */
@property (nonatomic, copy, readonly) NSNumber *destinationAppStoreIdentifier;

/**
 A unique, random value associated with this particular ad response for enhanced security.
 */
@property (nonatomic, copy, readonly) NSUUID   *nonce;

/**
 The app store identifier of the app displaying the ad.
 */
@property (nonatomic, copy, readonly) NSNumber *sourceAppStoreIdentifier;

/**
 The timestamp in unix time represented as milliseconds.
 */
@property (nonatomic, copy, readonly) NSNumber *timestamp;

/**
 The signature of the above data.
 */
@property (nonatomic, copy, readonly) NSString *signature;

#pragma mark SKStoreProductViewController Metadata Dictionary

/**
 A dictionary ready to be passed into an @c SKStoreProductViewController to show a clickthrough.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, __kindof NSObject *> *dictionaryForStoreProductViewController;

#pragma mark Not Allowed

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
