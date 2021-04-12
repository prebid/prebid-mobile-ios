//
//  OXAMoPubNativeAdRenderer.m
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//
#import <MoPub/MoPub.h>

@import OpenXApolloSDK;

#import "OXAMoPubNativeAdRenderer.h"

#import "OXAMoPubNativeAdAdapter.h"
#import "OXAMoPubNativeCustomEvent.h"

@interface OXAMoPubNativeAdRenderer() <MPNativeAdRendererImageHandlerDelegate>

@property (nonatomic, strong) UIView<MPNativeAdRendering> *adView;
@property (nonatomic, strong) OXAMoPubNativeAdAdapter *adapter;
@property (nonatomic, strong) Class renderingViewClass;
@property (nonatomic, strong) MPNativeAdRendererImageHandler *rendererImageHandler;
@property (nonatomic, assign) BOOL adViewInViewHierarchy;

@end

@implementation OXAMoPubNativeAdRenderer

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if (!(self = [super init])) {
        return nil;
    }
    
    MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
    _renderingViewClass = settings.renderingViewClass;
    _viewSizeHandler = [settings.viewSizeHandler copy];
    _rendererImageHandler = [[MPNativeAdRendererImageHandler alloc] init];
    _rendererImageHandler.delegate = self;
    
    return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[NSStringFromClass(OXAMoPubNativeCustomEvent.class)];
        
    return config;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError * _Nullable __autoreleasing *)error {
    if (!adapter || ![adapter isKindOfClass:[OXAMoPubNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        return nil;
    }
        
    self.adapter = adapter;
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.adapter.nativeAd registerView:self.adView clickableViews:@[]];
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        self.adView.nativeMainTextLabel.text = adapter.properties[kAdTextKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)] &&
        self.adView.nativeCallToActionTextLabel) {
        UILabel * const ctaLabel = self.adView.nativeCallToActionTextLabel;
        ctaLabel.text = [adapter.properties objectForKey:kAdCTATextKey];
        [self.adapter.nativeAd registerClickView:ctaLabel nativeAdElementType:OXANativeAdElementType_CallToAction];
    }
    
    if (adapter.properties[kAdSponsoredByCompanyKey] &&
        [self.adView respondsToSelector:@selector(nativeSponsoredByCompanyTextLabel)] &&
        self.adView.nativeSponsoredByCompanyTextLabel) {
        UILabel * const sponsoredLabel = self.adView.nativeSponsoredByCompanyTextLabel;
        sponsoredLabel.text = adapter.properties[kAdSponsoredByCompanyKey];
        
        OXANativeAdData *brandAsset = [self.adapter.nativeAd dataObjectsOfType:OXADataAssetType_Sponsored].firstObject;
        [self.adapter.nativeAd registerClickView:sponsoredLabel nativeAdAsset:brandAsset];
    }
    
    if (self.adapter.properties[kAdIconImageKey] &&
        [self.adView respondsToSelector:@selector(nativeIconImageView)]) {
        [self.adapter.nativeAd registerClickView:self.adView.nativeIconImageView
                             nativeAdElementType:OXANativeAdElementType_Icon];
    }
    
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        NSNumber *starRatingNum = adapter.properties[kAdStarRatingKey];

        if ([starRatingNum isKindOfClass:[NSNumber class]] &&
            starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
            [self.adView layoutStarRating:starRatingNum];
        }
    }
    
    if ([self shouldLoadMediaView]) {
        UIView *mediaView = [self.adapter mainMediaView];
        UIView *mainImageView = [self.adView nativeMainImageView];
        
        mediaView.frame = mainImageView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mainImageView.userInteractionEnabled = YES;
        
        [mainImageView addSubview:mediaView];
    }
    
    return self.adView;
}

- (void)adViewWillMoveToSuperview:(UIView *)superview {
    self.adViewInViewHierarchy = (superview != nil);
    
    if (!superview) {
        return;
    }
    
    if (self.adapter.properties[kAdIconImageKey] &&
        [self.adView respondsToSelector:@selector(nativeIconImageView)]) {
        [self.rendererImageHandler loadImageForURL:[NSURL URLWithString:self.adapter.properties[kAdIconImageKey]]               intoImageView:self.adView.nativeIconImageView];
    }
    
    UIView *mainMediaView = [self.adapter respondsToSelector:@selector(mainMediaView)] ? [self.adapter mainMediaView] : nil;
        
    if (!mainMediaView) {
        if (self.adapter.properties[kAdMainImageKey] &&
            [self.adView respondsToSelector:@selector(nativeMainImageView)]) {
            [self.rendererImageHandler loadImageForURL:[NSURL URLWithString:self.adapter.properties[kAdMainImageKey]]
                                         intoImageView:self.adView.nativeMainImageView];
        }
    }
}


#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy {
    return self.adViewInViewHierarchy;
}

#pragma mark - Private methods

- (BOOL)shouldLoadMediaView {
    return [self.adapter respondsToSelector:@selector(mainMediaView)] &&
           [self.adapter mainMediaView] &&
           [self.adView respondsToSelector:@selector(nativeMainImageView)];
}

@end
