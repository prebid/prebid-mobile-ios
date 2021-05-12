//
//  PBMApolloNativeAdAdapter.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <MoPub.h>

#import <PrebidMobileRendering/PBMNativeAd.h>

#import "PrebidMoPubNativeAdAdapter.h"

@interface PrebidMoPubNativeAdAdapter () <PBMNativeAdUIDelegate, PBMNativeAdTrackingDelegate>

@property (nonatomic, readonly) MediaView *mediaView;

@end

@implementation PrebidMoPubNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithPBMNativeAd:(PBMNativeAd *)nativeAd {
    if (!(self = [super init])) {
        return nil;
    }
    
    _nativeAd = nativeAd;
    _nativeAd.uiDelegate = self;
    _nativeAd.trackingDelegate = self;
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    properties[kAdTitleKey] = nativeAd.title;
    properties[kAdTextKey] = nativeAd.text;
    NSString * const sponsored = [nativeAd dataObjectsOfType:PBMDataAssetType_Sponsored].firstObject.value;
    properties[kAdSponsoredByCompanyKey] = sponsored;
    properties[kAdCTATextKey] = nativeAd.callToAction;
    
    NSString * const iconUrl = nativeAd.iconURL;
    if (iconUrl.length > 0) {
        properties[kAdIconImageKey] = iconUrl;
    }
    
    NSString * const imageUrl = nativeAd.imageURL;
    if (imageUrl.length > 0) {
        properties[kAdMainImageKey] = imageUrl;
    }
    
    NSString * const ratingString = [nativeAd dataObjectsOfType:PBMDataAssetType_Rating].firstObject.value;
    if (ratingString) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *ratingNum = [formatter numberFromString:ratingString];
        properties[kAdStarRatingKey] = ratingNum;
    }
    
    MediaData *mediaData = nativeAd.videoAd.mediaData;
    
    if (mediaData) {
        _mediaView = [[MediaView alloc] init];
        properties[kAdMainMediaViewKey] = _mediaView;
        [_mediaView load:mediaData];
    }
    
    _properties = properties;
    
    return self;
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL {
    return nil;
}

- (BOOL)enableThirdPartyClickTracking {
    return YES;
}

- (UIView *)mainMediaView {
    return self.mediaView;
}

#pragma mark - PBMNativeAdUIDelegate

- (nullable UIViewController *)viewPresentationControllerForNativeAd:(nonnull PBMNativeAd *)nativeAd {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)nativeAdWillLeaveApplication:(PBMNativeAd *)nativeAd {
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

- (void)nativeAdWillPresentModal:(PBMNativeAd *)nativeAd {
    MPLogEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)nativeAdDidDismissModal:(PBMNativeAd *)nativeAd {
    MPLogEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

#pragma mark - PBMNativeAdTrackingDelegate

- (void)nativeAdDidLogClick:(PBMNativeAd *)nativeAd {
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
        MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)]);
    } else {
        MPLogInfo(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
}

- (void)nativeAd:(PBMNativeAd *)nativeAd didLogEvent:(PBMNativeEventType)nativeEvent {
    if (nativeEvent == PBMNativeEventType_Impression) {
        if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
            MPLogEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)]);
            MPLogEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)]);
            [self.delegate nativeAdWillLogImpression:self];
        } else {
            MPLogInfo(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
        }
    }
}

@end
