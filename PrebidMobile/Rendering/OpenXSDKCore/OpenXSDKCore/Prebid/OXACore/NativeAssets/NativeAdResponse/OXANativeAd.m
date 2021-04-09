//
//  OXANativeAd.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAd.h"
#import "OXANativeAd+Testing.h"
#import "OXANativeAd+FromMarkup.h"
#import "OXANativeAdAsset+FromMarkup.h"
#import "OXANativeAdVideo+Internal.h"

// impression tracking {
#import "NSTimer+OXAScheduledTimerFactory.h"
#import "OXANativeAdImpressionReporting.h"
#import "OXANativeImpressionsTracker.h"
// }

// click tracking {
#import "OXAClickthroughBrowserOpener.h"
#import "OXMDeepLinkPlusHelper+OXAExternalLinkHandler.h"
#import "OXAExternalLinkHandler.h"
#import "OXAExternalURLOpeners.h"
#import "OXANativeClickableViewRegistry.h"
#import "OXANativeClickTrackerBinders.h"
#import "OXATrackingURLVisitors.h"
#import "OXMModalManager.h"
// }

// open measurement support {
#import "OXMOpenMeasurementSession.h"
#import "OXMOpenMeasurementWrapper.h"
// }

#import "OXMServerConnection.h"

#import "OXMMacros.h"


static NSTimeInterval const VIEWABILITY_POLLING_INTERVAL = 0.2;


@interface OXANativeAd ()
@property (nonatomic, strong, nonnull, readonly) OXANativeAdMarkup *nativeAdMarkup;
@property (nonatomic, strong, nonnull, readonly) OXANativeImpressionDetectionHandler fireEventTrackersBlock;
@property (nonatomic, strong, nonnull, readonly) OXANativeViewClickHandlerBlock nativeClickHandlerBlock;
@property (nonatomic, strong, nonnull, readonly) OXANativeClickableViewRegistry *clickableViewRegistry;

@property (nonatomic, strong, nullable) OXANativeImpressionsTracker *impressionTracker;

@property (nonatomic, strong) OXMOpenMeasurementWrapper *measurementWrapper;
@property (nonatomic, strong, nullable) OXMOpenMeasurementSession *measurementSession;
@end


@implementation OXANativeAd

// MARK: - Lifecycle

- (instancetype)initWithNativeAdMarkup:(OXANativeAdMarkup *)nativeAdMarkup {
    return (self = [self initWithNativeAdMarkup:nativeAdMarkup
                                    application:[UIApplication sharedApplication]
                             measurementWrapper:[OXMOpenMeasurementWrapper singleton]
                               serverConnection:[OXMServerConnection singleton]
                               sdkConfiguration:[OXASDKConfiguration singleton]]);
}

- (instancetype)initWithNativeAdMarkup:(OXANativeAdMarkup *)nativeAdMarkup
                           application:(id<OXMUIApplicationProtocol>)application
                    measurementWrapper:(OXMOpenMeasurementWrapper *)measurementWrapper
                      serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                      sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
{
    if (!(self = [super init])) {
        return nil;
    }
    _nativeAdMarkup = nativeAdMarkup;
    
    OXAExternalURLOpenerBlock const appUrlOpener = [OXAExternalURLOpeners applicationAsExternalUrlOpener:application];
    OXATrackingURLVisitorBlock const trackingUrlVisitor = [OXATrackingURLVisitors connectionAsTrackingURLVisitor:serverConnection];
    
    OXAExternalLinkHandler * const appUrlLinkHandler = [[OXAExternalLinkHandler alloc] initWithPrimaryUrlOpener:appUrlOpener
                                                                                              deepLinkUrlOpener:appUrlOpener
                                                                                             trackingUrlVisitor:trackingUrlVisitor];
    
    OXMModalManager * const modalManager = [[OXMModalManager alloc] initWithDelegate:nil];
    
    @weakify(self);
    
    OXAClickthroughBrowserOpener * const
    clickthroughOpener = [[OXAClickthroughBrowserOpener alloc] initWithSDKConfiguration:sdkConfiguration
                                                                        adConfiguration:nil
                                                                           modalManager:modalManager
                                                                 viewControllerProvider:^UIViewController * _Nullable{
        @strongify(self);
        id<OXANativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(viewPresentationControllerForNativeAd:)]) {
            return [delegate viewPresentationControllerForNativeAd:self];
        } else {
            return nil;
        }
    } measurementSessionProvider: ^OXMOpenMeasurementSession * _Nullable{
        @strongify(self);
        return self.measurementSession;
    } onWillLoadURLInClickthrough:^{
        @strongify(self);
        id<OXANativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdWillPresentModal:)]) {
            return [delegate nativeAdWillPresentModal:self];
        }
    } onWillLeaveAppBlock:^{
        @strongify(self);
        id<OXANativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdWillLeaveApplication:)]) {
            return [delegate nativeAdWillLeaveApplication:self];
        }
    } onClickthroughPoppedBlock:^(OXMModalState * _Nonnull poppedState) {
        @strongify(self);
        id<OXANativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdDidDismissModal:)]) {
            return [delegate nativeAdDidDismissModal:self];
        }
    } onDidLeaveAppBlock:^(OXMModalState * _Nonnull leavingState) {
        @strongify(self);
        id<OXANativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdWillLeaveApplication:)]) {
            return [delegate nativeAdWillLeaveApplication:self];
        }
    }];
    
    OXAExternalLinkHandler * const clickthroughLinkHandler = [appUrlLinkHandler handlerByAddingUrlOpenAttempter:clickthroughOpener.asUrlOpenAttempter];
    // TODO: Enable 'deeplink+' support
#   ifdef DEBUG
    // Note: keep unused variable to ensure the code compiles for later use
    OXAExternalLinkHandler * const deepLinkPlusHandler __attribute__((unused)) = [OXMDeepLinkPlusHelper deepLinkPlusHandlerWithExternalLinkHandler:clickthroughLinkHandler];
#   endif
    OXAExternalLinkHandler * const externalLinkHandler = clickthroughLinkHandler;
    
    _fireEventTrackersBlock = [OXANativeAdImpressionReporting impressionReporterWithEventTrackers:nativeAdMarkup.eventtrackers
                                                                                       urlVisitor:trackingUrlVisitor];
    
    OXMVoidBlock const reportSelfClicked = ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        [self trackOMEvent:OXMTrackingEventClick];
        
        id<OXANativeAdTrackingDelegate> const delegate = self.trackingDelegate;
        if (delegate && [delegate respondsToSelector:@selector(nativeAdDidLogClick:)]) {
            [delegate nativeAdDidLogClick:self];
        }
    };
    OXANativeViewClickHandlerBlock const nativeClickHandler = ^(NSString *url,
                                                                NSString * _Nullable fallback,
                                                                NSArray<NSString *> * _Nullable clicktrackers,
                                                                OXMVoidBlock _Nullable onClickthroughExitBlock)
    {
        OXMVoidBlock const tryFallbackUrl = ^{
            NSURL * const fallbackUrl = (fallback != nil) ? [NSURL URLWithString:fallback] : nil;
            if (fallbackUrl != nil) {
                [externalLinkHandler openExternalUrl:fallbackUrl trackingUrls:clicktrackers completion:^(BOOL success) {
                    reportSelfClicked();
                } onClickthroughExitBlock:onClickthroughExitBlock];
            } else {
                reportSelfClicked();
            }
        };
        NSURL * const mainUrl = (url != nil) ? [NSURL URLWithString:url] : nil;
        if (mainUrl == nil) {
            tryFallbackUrl();
            return;
        }
        [externalLinkHandler openExternalUrl:mainUrl trackingUrls:clicktrackers completion:^(BOOL success) {
            if (success) {
                reportSelfClicked();
                return;
            } else {
                tryFallbackUrl();
            }
        } onClickthroughExitBlock:onClickthroughExitBlock];
    };
    _nativeClickHandlerBlock = nativeClickHandler;
    
    OXANativeClickTrackerBinderFactoryBlock const clickBinderFactory = [OXANativeClickTrackerBinders smartBinder];
    
    _clickableViewRegistry = [[OXANativeClickableViewRegistry alloc] initWithBinderFactory:clickBinderFactory
                                                                              clickHandler:nativeClickHandler];
    
    _measurementWrapper = measurementWrapper;
    
    return self;
}

// MARK: - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    OXANativeAd *other = object;
    return (self == other) || [self.nativeAdMarkup isEqual:other.nativeAdMarkup];
}

// MARK: - Public API (Root properties)

- (NSString *)version {
    return self.nativeAdMarkup.version ?: @"";
}

// MARK: - Public API (Convenience getters)

- (NSString *)title {
    NSArray<OXANativeAdTitle *> * const titles = self.titles;
    NSString * const title = (titles.count > 0) ? titles[0].text : nil;
    return title ?: @"";
}

- (NSString *)text {
    NSArray<OXANativeAdData *> * const descriptions = [self dataObjectsOfType:OXADataAssetType_Desc];
    NSString * const description = (descriptions.count > 0) ? descriptions[0].value : nil;
    return description ?: @"";
}

- (NSString *)iconURL {
    NSArray<OXANativeAdImage *> * const icons = [self imagesOfType:OXAImageAssetType_Icon];
    NSString * const icon = (icons.count > 0) ? icons[0].url : nil;
    return icon ?: @"";
}

- (NSString *)imageURL {
    NSArray<OXANativeAdImage *> * const images = [self imagesOfType:OXAImageAssetType_Main];
    NSString * const image = (images.count > 0) ? images[0].url : nil;
    return image ?: @"";
}

- (nullable OXANativeAdVideo *)videoAd {
    NSArray<OXANativeAdVideo *> * const videoAds = self.videoAds;
    if (videoAds.count > 0) {
        return videoAds[0];
    } else {
        return nil;
    }
}

- (NSString *)callToAction {
    NSArray<OXANativeAdData *> * const callToActions = [self dataObjectsOfType:OXADataAssetType_CTAText];
    NSString * const callToAction = (callToActions.count > 0) ? callToActions[0].value : nil;
    return callToAction ?: @"";
}

// MARK: - Public API (Array getters)

- (NSArray<OXANativeAdTitle *> *)titles {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<OXANativeAdTitle *> * const result = [[NSMutableArray alloc] init];
    for (OXANativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        OXANativeAdTitle * const nextTitle = [[OXANativeAdTitle alloc] initWithNativeAdMarkupAsset:nextAsset error:nil];
        if (nextTitle) {
            [result addObject:nextTitle];
        }
    }
    return result;
}

- (NSArray<OXANativeAdData *> *)dataObjects {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<OXANativeAdData *> * const result = [[NSMutableArray alloc] init];
    for (OXANativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        OXANativeAdData * const nextData = [[OXANativeAdData alloc] initWithNativeAdMarkupAsset:nextAsset error:nil];
        if (nextData) {
            [result addObject:nextData];
        }
    }
    return result;
}

- (NSArray<OXANativeAdImage *> *)images {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<OXANativeAdImage *> * const result = [[NSMutableArray alloc] init];
    for (OXANativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        OXANativeAdImage * const nextImage = [[OXANativeAdImage alloc] initWithNativeAdMarkupAsset:nextAsset error:nil];
        if (nextImage) {
            [result addObject:nextImage];
        }
    }
    return result;
}

- (NSArray<OXANativeAdVideo *> *)videoAds {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<OXANativeAdVideo *> * const result = [[NSMutableArray alloc] init];
    @weakify(self);
    OXAViewControllerProvider const viewControllerProvider = ^UIViewController * _Nullable{
        @strongify(self);
        return [self.uiDelegate viewPresentationControllerForNativeAd:self];
    };
    OXANativeViewClickHandlerBlock const nativeClickHandler = self.nativeClickHandlerBlock;
    for (OXANativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        OXANativeAdMarkupLink * const markupLink = nextAsset.link ?: self.nativeAdMarkup.link;
        OXACreativeClickHandlerBlock const clickHandlerOverride = ((markupLink == nil)
                                                                   ? nil
                                                                   : ^(OXMVoidBlock  _Nonnull onClickthroughExitBlock) {
            nativeClickHandler(markupLink.url, markupLink.fallback, markupLink.clicktrackers, onClickthroughExitBlock);
        });
        OXANativeAdMediaHooks * const
        nativeAdHooks = [[OXANativeAdMediaHooks alloc] initWithViewControllerProvider:viewControllerProvider
                                                                 clickHandlerOverride:clickHandlerOverride];
        OXANativeAdVideo * const nextVideo = [[OXANativeAdVideo alloc] initWithNativeAdMarkupAsset:nextAsset
                                                                                     nativeAdHooks:nativeAdHooks
                                                                                             error:nil];
        if (nextVideo) {
            [result addObject:nextVideo];
        }
    }
    return result;
}

- (NSArray<NSString *> *)imptrackers {
    return self.nativeAdMarkup.imptrackers ?: @[];
}

// MARK: - Public API (Filtered array getters)

- (NSArray<OXANativeAdData *> *)dataObjectsOfType:(OXADataAssetType)dataType {
    NSMutableArray<OXANativeAdData *> * const result = [[NSMutableArray alloc] init];
    for (OXANativeAdData *nextData in self.dataObjects) {
        if (nextData.dataType.integerValue == dataType) {
            [result addObject:nextData];
        }
    }
    return result;
}

- (NSArray<OXANativeAdImage *> *)imagesOfType:(OXAImageAssetType)imageType {
    NSMutableArray<OXANativeAdImage *> * const result = [[NSMutableArray alloc] init];
    for (OXANativeAdImage *nextImage in self.images) {
        if (nextImage.imageType.integerValue == imageType) {
            [result addObject:nextImage];
        }
    }
    return result;
}

// MARK: - Public API (View handling)

- (void)registerView:(UIView *)adView clickableViews:(nullable NSArray<UIView *> *)clickableViews {
    if (self.impressionTracker) {
        // TODO: Log error?
        return;
    }
    @weakify(self);
    self.impressionTracker = [[OXANativeImpressionsTracker alloc] initWithView:adView
                                                               pollingInterval:VIEWABILITY_POLLING_INTERVAL
                                                         scheduledTimerFactory:[NSTimer oxaScheduledTimerFactory]
                                                    impressionDetectionHandler:^(OXANativeEventType impressionType) {
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        if (impressionType == OXANativeEventType_Impression) {
            [self trackOMEvent:OXMTrackingEventImpression];
        }
        
        self.fireEventTrackersBlock(impressionType);
        id<OXANativeAdTrackingDelegate> const delegate = self.trackingDelegate;
        if (delegate && [delegate respondsToSelector:@selector(nativeAd:didLogEvent:)]) {
            [delegate nativeAd:self didLogEvent:impressionType];
        }
    }];
    
    if (clickableViews.count > 0 && self.nativeAdMarkup.link != nil) {
        for (UIView *nextView in clickableViews) {
            [self.clickableViewRegistry registerLink:self.nativeAdMarkup.link forView:nextView];
        }
    }
    
    [self createOpenMeasurementSession:adView];
}

- (void)registerClickView:(UIView *)adView nativeAdElementType:(OXANativeAdElementType)nativeAdElementType {
    OXANativeAdAsset * const relevantAsset = [self findAssetForElementType:nativeAdElementType];
    [self registerClickView:adView nativeAdAsset:relevantAsset];
}

- (void)registerClickView:(UIView *)adView nativeAdAsset:(OXANativeAdAsset *)nativeAdAsset {
    OXANativeAdMarkupLink * const relevantLink = nativeAdAsset.link ?: self.nativeAdMarkup.link;
    [self.clickableViewRegistry registerLink:relevantLink forView:adView];
}

// MARK: - Private Helpers

- (nullable OXANativeAdAsset *)findAssetForElementType:(OXANativeAdElementType)nativeAdElementType {
    NSArray<OXANativeAdAsset *> *assets = nil;
    switch (nativeAdElementType) {
        case OXANativeAdElementType_Title:
            assets = self.titles;
            break;
        case OXANativeAdElementType_Text:
            assets = [self dataObjectsOfType:OXADataAssetType_Desc];
            break;
        case OXANativeAdElementType_Icon:
            assets = [self imagesOfType:OXAImageAssetType_Icon];
            break;
        case OXANativeAdElementType_Image:
            assets = [self imagesOfType:OXAImageAssetType_Main];
            break;
        case OXANativeAdElementType_VideoAd:
            assets = self.videoAds;
            break;
        case OXANativeAdElementType_CallToAction:
            assets = [self dataObjectsOfType:OXADataAssetType_CTAText];
            break;
        default:
            return nil;
    }
    return (assets.count > 0) ? assets[0] : nil;
}

// MARK: - Private Helpers (OpenMeasurement support)

- (void)createOpenMeasurementSession:(UIView *)adView {
    if (!NSThread.currentThread.isMainThread) {
        OXMLogError(@"Open Measurement session can only be created on the main thread");
        return;
    }
    
    OXANativeAdMarkupEventTracker *omTracker = [self findOMIDTracker];
    
    if (omTracker) {
        self.measurementSession = [self.measurementWrapper initializeNativeDisplaySession:adView
                                                                                omidJSUrl:omTracker.url
                                                                                vendorKey:omTracker.ext[@"vendorKey"]
                                                                               parameters:omTracker.ext[@"verification_parameters"]];
        
        if (self.measurementSession) {
            [self.measurementSession start];
        }
    }
}

- (nullable OXANativeAdMarkupEventTracker *)findOMIDTracker {
    for(OXANativeAdMarkupEventTracker *omTracker in self.nativeAdMarkup.eventtrackers) {
        if (omTracker.event == OXANativeEventType_OMID &&
            omTracker.method == OXANativeEventTrackingMethod_JS &&
            omTracker.url) {
            return omTracker;
        }
    }
    return nil;
}

- (void)trackOMEvent:(OXMTrackingEvent) event {
    if (!self.measurementSession) {
        OXMLogError(@"Measurement Session is missed.");
        return;
    }
    
    if (event == OXMTrackingEventImpression) {
        [self.measurementSession.eventTracker trackEvent:OXMTrackingEventLoaded];
    }
    
    [self.measurementSession.eventTracker trackEvent:event];
}

@end
