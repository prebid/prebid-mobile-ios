//
//  MPSKAdNetworkClickthroughData.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPSKAdNetworkClickthroughData.h"

#import <StoreKit/StoreKit.h>

// Intentionally casting to suppress the static analyzer.
// Since we validate that all values are non-nil in `isClickthroughDataValid`,
// we'll never return an object with nil values from init.
#define NULLABLE_STRING_TO_NULLABLE_NSNUMBER(str) str == nil ? (id _Nonnull)nil : (id _Nonnull)@([str longLongValue])

static NSString *const kAdServerVersionKey                       = @"version";
static NSString *const kAdServerNetworkKey                       = @"network";
static NSString *const kAdServerCampaignKey                      = @"campaign";
static NSString *const kAdServerDestinationAppStoreIdentifierKey = @"itunesitem";
static NSString *const kAdServerNonceKey                         = @"nonce";
static NSString *const kAdServerSourceAppStoreIdentifierKey      = @"sourceapp";
static NSString *const kAdServerTimestampKey                     = @"timestamp";
static NSString *const kAdServerSignatureKey                     = @"signature";

@implementation MPSKAdNetworkClickthroughData

- (instancetype)initWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary {
    if (self = [super init]) {
        // If iOS 14+ is available, continue with initialization
        // If not, fail it by returning @c nil
        // The compiler doesn't like `!@available`, so unfortunately a pyramid
        // must be used with the failure case at the bottom
        if (@available(iOS 14.0, *)) {
            _version = dictionary[kAdServerVersionKey];
            _networkIdentifier = dictionary[kAdServerNetworkKey];
            _campaignIdentifier = NULLABLE_STRING_TO_NULLABLE_NSNUMBER(dictionary[kAdServerCampaignKey]);
            _destinationAppStoreIdentifier = NULLABLE_STRING_TO_NULLABLE_NSNUMBER(dictionary[kAdServerDestinationAppStoreIdentifierKey]);
            _nonce = [[NSUUID alloc] initWithUUIDString:dictionary[kAdServerNonceKey]];
            _sourceAppStoreIdentifier = NULLABLE_STRING_TO_NULLABLE_NSNUMBER(dictionary[kAdServerSourceAppStoreIdentifierKey]);
            _timestamp = NULLABLE_STRING_TO_NULLABLE_NSNUMBER(dictionary[kAdServerTimestampKey]);
            _signature = dictionary[kAdServerSignatureKey];

            // Validate the clickthrough data before continuing. If the data is not valid, fail the initialization
            // by returning @c nil.
            if (![self isClickthroughDataValid]) {
                return nil;
            }

            _dictionaryForStoreProductViewController = [self assembleDictionaryForStoreProductViewController];
        }
        else {
            return nil;
        }
    }

    return self;
}

- (NSDictionary *)assembleDictionaryForStoreProductViewController API_AVAILABLE(ios(14.0)) {
    return @{
        SKStoreProductParameterAdNetworkVersion:                  self.version,
        SKStoreProductParameterAdNetworkIdentifier:               self.networkIdentifier,
        SKStoreProductParameterAdNetworkCampaignIdentifier:       self.campaignIdentifier,
        SKStoreProductParameterITunesItemIdentifier:              self.destinationAppStoreIdentifier,
        SKStoreProductParameterAdNetworkNonce:                    self.nonce,
        SKStoreProductParameterAdNetworkSourceAppStoreIdentifier: self.sourceAppStoreIdentifier,
        SKStoreProductParameterAdNetworkTimestamp:                self.timestamp,
        SKStoreProductParameterAdNetworkAttributionSignature:     self.signature,
    };
}

- (BOOL)isClickthroughDataValid {
    return _version != nil
    && _networkIdentifier != nil
    && _campaignIdentifier != nil
    && _destinationAppStoreIdentifier != nil
    && _nonce != nil
    && _sourceAppStoreIdentifier != nil
    && _timestamp != nil
    && _signature != nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n{\n\tAPI Version: %@\n\tNetwork ID: %@\n\tCampaign ID: %@\n\tDestination App ID: %@\n\tNonce: %@\n\tSource App ID: %@\n\tTimestamp: %@\n\tSignature: %@\n}",
            [super description],
            self.version,
            self.networkIdentifier,
            self.campaignIdentifier,
            self.destinationAppStoreIdentifier,
            self.nonce,
            self.sourceAppStoreIdentifier,
            self.timestamp,
            self.signature
            ];
}

@end
