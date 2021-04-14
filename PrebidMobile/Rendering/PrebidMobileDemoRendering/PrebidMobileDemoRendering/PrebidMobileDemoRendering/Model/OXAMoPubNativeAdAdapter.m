//
//  OXAApolloNativeAdAdapter.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import OpenXApolloSDK;

#import "OXAMoPubNativeAdAdapter.h"


@interface OXAMoPubNativeAdAdapter () <OXANativeAdUIDelegate, OXANativeAdTrackingDelegate>

@property (nonatomic, strong) OXANativeAd *nativeAd;

@end

@implementation OXAMoPubNativeAdAdapter

@synthesize defaultActionURL;

@synthesize properties = _properties;

- (instancetype)initWithOXANativeAd:(OXANativeAd *)nativeAd {
    if (!(self = [super init])) {
        return nil;
    }
    
    _nativeAd = nativeAd;
    _nativeAd.uiDelegate = self;
    _nativeAd.trackingDelegate = self;
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    properties[kAdTitleKey] = nativeAd.title;
    properties[kAdTextKey] = nativeAd.text;
    
    NSString * const iconUrl = nativeAd.iconURL;
    if (iconUrl.length > 0) {
        properties[kAdIconImageKey] = iconUrl;
    }
    
    NSString * const imageUrl = nativeAd.imageURL;
    if (imageUrl.length > 0) {
        properties[kAdMainImageKey] = imageUrl;
    }
    
    properties[kAdCTATextKey] = nativeAd.callToAction;
    
    return self;
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL {
    return nil; //base Ad URL ??
}

- (BOOL)enableThirdPartyClickTracking {
    return YES;
}

- (void)willAttachToView:(UIView *)view {
    [self willAttachToView:view withAdContentViews:nil];
}

- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews {
    NSLog(@"XBAL WILL ATTACH TO %@ views %@", view, adContentViews);
    [self.nativeAd registerView:view clickableViews:adContentViews];
}

#pragma mark - OXANativeAdUIDelegate

- (nullable UIViewController *)viewPresentationControllerForNativeAd:(nonnull OXANativeAd *)nativeAd {
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)nativeAdWillLeaveApplication:(OXANativeAd *)nativeAd {
    MPLogEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdWillLeaveApplicationFromAdapter:self];
}

- (void)nativeAdWillPresentModal:(OXANativeAd *)nativeAd {
    MPLogEvent([MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (void)nativeAdDidDismissModal:(OXANativeAd *)nativeAd {
    MPLogEvent([MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)]);
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

#pragma mark - OXANativeAdTrackingDelegate

- (void)nativeAdDidLogClick:(OXANativeAd *)nativeAd {
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
        MPLogEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)]);
    } else {
        MPLogInfo(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
}

- (void)nativeAd:(OXANativeAd *)nativeAd didLogEvent:(OXANativeEventType)nativeEvent {
    if (nativeEvent == OXANativeEventType_Impression) {
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
