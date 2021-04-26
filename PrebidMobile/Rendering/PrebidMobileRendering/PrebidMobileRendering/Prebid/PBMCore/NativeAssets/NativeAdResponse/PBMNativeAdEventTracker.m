//
//  PBMNativeAdEventTracker.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdEventTracker.h"
#import "PBMNativeAdEventTracker+FromMarkup.h"

@interface PBMNativeAdEventTracker ()
@property (nonatomic, strong, nonnull, readonly) PBMNativeAdMarkupEventTracker *nativeAdMarkupEventTracker;
@end

@implementation PBMNativeAdEventTracker

// MARK: - Lifecycle

- (instancetype)initWithNativeAdMarkupEventTracker:(PBMNativeAdMarkupEventTracker *)nativeAdMarkupEventTracker {
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
    PBMNativeAdEventTracker *other = object;
    return (self == other) || [self.nativeAdMarkupEventTracker isEqual:other.nativeAdMarkupEventTracker];
}

// MARK: - Public properties

- (PBMNativeEventType)event {
    return self.nativeAdMarkupEventTracker.event;
}

- (PBMNativeEventTrackingMethod)method {
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
