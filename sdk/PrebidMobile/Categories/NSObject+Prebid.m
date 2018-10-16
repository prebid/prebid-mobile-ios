
/*   Copyright 2017 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <CoreLocation/CoreLocation.h>
#import "PBBidManager.h"
#import "PBKeywordsManager.h"
#import "NSObject+Prebid.h"
#import "NSString+Extension.h"
#import <objc/runtime.h>

@implementation NSObject (Prebid)

@dynamic pb_identifier;

+ (void)load {
    static dispatch_once_t loadToken;
    dispatch_once(&loadToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [NSClassFromString(@"GADSlot") pb_swizzleInstanceSelector:@selector(requestParameters)
                                                         withSelector:@selector(pb_requestParameters)];
            [NSClassFromString(@"MPBannerAdManager") pb_swizzleInstanceSelector:@selector(loadAd)
                                                                   withSelector:@selector(pb_loadAd)];
            [NSClassFromString(@"MPBannerAdManager") pb_swizzleInstanceSelector:@selector(forceRefreshAd)
                                                                   withSelector:@selector(pb_forceRefreshAd)];
            [NSClassFromString(@"MPBannerAdManager") pb_swizzleInstanceSelector:@selector(applicationWillEnterForeground)
                                                                   withSelector:@selector(pb_applicationWillEnterForeground)];
            [NSClassFromString(@"MPInterstitialAdManager") pb_swizzleInstanceSelector:@selector(loadInterstitialWithAdUnitID:keywords:location:testing:)
                                                                         withSelector:@selector(pb_loadInterstitialWithAdUnitID:keywords:location:testing:)];
            [NSClassFromString(@"AFAdInline") pb_swizzleInstanceSelector:@selector(loadAd)
                                                            withSelector:@selector(pb_loadInlineAd)];
#pragma clang diagnostic pop
        });
    });
}

+ (void)pb_swizzleInstanceSelector:(SEL)originalSelector
                      withSelector:(SEL)swizzledSelector {
    Class class = [self class];

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// dfp ad slot
- (id)pb_requestParameters {
    __block id requestParameters = [self pb_requestParameters];

    SEL adEventDelegateSel = NSSelectorFromString(@"adEventDelegate");
    if ([self respondsToSelector:adEventDelegateSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id adEventDelegate = [self performSelector:adEventDelegateSel];
        NSDictionary<NSString *, NSString *> *keywordsPairs;

        SEL getPb_identifier = NSSelectorFromString(@"pb_identifier");
        if ([adEventDelegate respondsToSelector:getPb_identifier]) {
            PBAdUnit *adUnit = (PBAdUnit *)[adEventDelegate performSelector:getPb_identifier];
#pragma clang diagnostic pop

            if (adUnit) {
                keywordsPairs = [[PBBidManager sharedInstance] keywordsForWinningBidForAdUnit:adUnit];
                requestParameters = [[PBBidManager sharedInstance] addPrebidParameters:requestParameters withKeywords:keywordsPairs];
            }
        }
    }
    return requestParameters;
}

// mopub banner
- (void)pb_applicationWillEnterForeground {
    SEL getDelegate = NSSelectorFromString(@"delegate");
    if ([self respondsToSelector:getDelegate]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id delegate = [self performSelector:getDelegate];
        SEL getBannerAd = NSSelectorFromString(@"banner");
        if ([delegate respondsToSelector:getBannerAd]) {
            NSObject *adView = [delegate performSelector:getBannerAd];
#pragma clang diagnostic pop
            [[PBBidManager sharedInstance] setBidOnAdObject:adView];
            [self pb_applicationWillEnterForeground];
            [[PBBidManager sharedInstance] clearBidOnAdObject:adView];
        }
    };
}

- (void)pb_loadAd {
    SEL getDelegate = NSSelectorFromString(@"delegate");
    if ([self respondsToSelector:getDelegate]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id delegate = [self performSelector:getDelegate];
        SEL getBannerAd = NSSelectorFromString(@"banner");
        if ([delegate respondsToSelector:getBannerAd]) {
            NSObject *adView = [delegate performSelector:getBannerAd];
#pragma clang diagnostic pop
            [[PBBidManager sharedInstance] setBidOnAdObject:adView];
            [self pb_loadAd];
            [[PBBidManager sharedInstance] clearBidOnAdObject:adView];
        }
    };
}

- (void)pb_forceRefreshAd {
    SEL getDelegate = NSSelectorFromString(@"delegate");
    if ([self respondsToSelector:getDelegate]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id delegate = [self performSelector:getDelegate];
        SEL getBannerAd = NSSelectorFromString(@"banner");
        if ([delegate respondsToSelector:getBannerAd]) {
            NSObject *adView = [delegate performSelector:getBannerAd];
#pragma clang diagnostic pop
            [[PBBidManager sharedInstance] setBidOnAdObject:adView];
            [self pb_forceRefreshAd];
            [[PBBidManager sharedInstance] clearBidOnAdObject:adView];
        }
    };
}

// mopub interstitial
- (void)pb_loadInterstitialWithAdUnitID:(NSString *)ID keywords:(NSString *)keywords location:(CLLocation *)location testing:(BOOL)testing {
    SEL getDelegate = NSSelectorFromString(@"delegate");
    if ([self respondsToSelector:getDelegate]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id delegate = [self performSelector:getDelegate];
        SEL getInterstitialAd = NSSelectorFromString(@"interstitialAdController");
        if ([delegate respondsToSelector:getInterstitialAd]) {
            NSObject *interstitialAd = [delegate performSelector:getInterstitialAd];
            SEL getAdUnitId = NSSelectorFromString(@"adUnitId");
            SEL getKeywords = NSSelectorFromString(@"keywords");
            SEL getLocation = NSSelectorFromString(@"location");
            if ([delegate respondsToSelector:getAdUnitId] && [delegate respondsToSelector:getKeywords] && [delegate respondsToSelector:getLocation]) {
                NSString *adUnitId = (NSString *)[interstitialAd performSelector:getAdUnitId];
                CLLocation *location = (CLLocation *)[interstitialAd performSelector:getLocation];
                [[PBBidManager sharedInstance] setBidOnAdObject:interstitialAd];
                NSString *keywords = (NSString *)[interstitialAd performSelector:getKeywords];
                [self pb_loadInterstitialWithAdUnitID:adUnitId keywords:keywords location:location testing:testing];
#pragma clang diagnostic pop
                [[PBBidManager sharedInstance] clearBidOnAdObject:interstitialAd];
            }
        }
    };
}

// adform banner

- (void)pb_loadInlineAd {
    [[PBBidManager sharedInstance] setBidParametersOnAdObject:self];
    [self pb_loadInlineAd];
}

- (void)setPb_identifier:(PBAdUnit *)pb_identifier {
    objc_setAssociatedObject(self, @selector(pb_identifier), pb_identifier,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PBAdUnit *)pb_identifier {
    return objc_getAssociatedObject(self, @selector(pb_identifier));
}

@end
