//
//  OXANativeAdEventTracker.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdEventTracker.h"
#import "OXANativeAdEventTracker+FromMarkup.h"

@interface OXANativeAdEventTracker ()
@property (nonatomic, strong, nonnull, readonly) OXANativeAdMarkupEventTracker *nativeAdMarkupEventTracker;
@end

@implementation OXANativeAdEventTracker

// MARK: - Lifecycle

- (instancetype)initWithNativeAdMarkupEventTracker:(OXANativeAdMarkupEventTracker *)nativeAdMarkupEventTracker {
    if (!(self = [super init])) {
        return nil;
    }
    _nativeAdMarkupEventTracker = nativeAdMarkupEventTracker;
    return self;
}

// MARK: - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    OXANativeAdEventTracker *other = object;
    return (self == other) || [self.nativeAdMarkupEventTracker isEqual:other.nativeAdMarkupEventTracker];
}

// MARK: - Public properties

- (OXANativeEventType)event {
    return self.nativeAdMarkupEventTracker.event;
}

- (OXANativeEventTrackingMethod)method {
    return self.nativeAdMarkupEventTracker.method;
}

- (NSString *)url {
    return self.nativeAdMarkupEventTracker.url;
}

- (NSDictionary<NSString *,id> *)customdata {
    return self.nativeAdMarkupEventTracker.customdata;
}

- (NSDictionary<NSString *,id> *)ext {
    return self.nativeAdMarkupEventTracker.ext;
}

@end
