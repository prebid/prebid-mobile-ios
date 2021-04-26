//
//  PBMNativeAd.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAd.h"
#import "PBMNativeAd+Testing.h"
#import "PBMNativeAd+FromMarkup.h"
#import "PBMNativeAdAsset+FromMarkup.h"
#import "PBMNativeAdVideo+Internal.h"

// impression tracking {
#import "NSTimer+PBMScheduledTimerFactory.h"
#import "PBMNativeAdImpressionReporting.h"
#import "PBMNativeImpressionsTracker.h"
// }

// click tracking {
#import "PBMClickthroughBrowserOpener.h"
#import "PBMDeepLinkPlusHelper+PBMExternalLinkHandler.h"
#import "PBMExternalLinkHandler.h"
#import "PBMExternalURLOpeners.h"
#import "PBMNativeClickableViewRegistry.h"
#import "PBMNativeClickTrackerBinders.h"
#import "PBMTrackingURLVisitors.h"
#import "PBMModalManager.h"
// }

// open measurement support {
#import "PBMOpenMeasurementSession.h"
#import "PBMOpenMeasurementWrapper.h"
// }

#import "PBMServerConnection.h"

#import "PBMMacros.h"


static NSTimeInterval const VIEWABILITY_POLLING_INTERVAL = 0.2;


@interface PBMNativeAd ()
@property (nonatomic, strong, nonnull, readonly) PBMNativeAdMarkup *nativeAdMarkup;
@property (nonatomic, strong, nonnull, readonly) PBMNativeImpressionDetectionHandler fireEventTrackersBlock;
@property (nonatomic, strong, nonnull, readonly) PBMNativeViewClickHandlerBlock nativeClickHandlerBlock;
@property (nonatomic, strong, nonnull, readonly) PBMNativeClickableViewRegistry *clickableViewRegistry;

@property (nonatomic, strong, nullable) PBMNativeImpressionsTracker *impressionTracker;

@property (nonatomic, strong) PBMOpenMeasurementWrapper *measurementWrapper;
@property (nonatomic, strong, nullable) PBMOpenMeasurementSession *measurementSession;
@end


@implementation PBMNativeAd

// MARK: - Lifecycle

- (instancetype)initWithNativeAdMarkup:(PBMNativeAdMarkup *)nativeAdMarkup {
    return (self = [self initWithNativeAdMarkup:nativeAdMarkup
                                    application:[UIApplication sharedApplication]
                             measurementWrapper:[PBMOpenMeasurementWrapper singleton]
                               serverConnection:[PBMServerConnection singleton]
                               sdkConfiguration:[PBMSDKConfiguration singleton]]);
}

- (instancetype)initWithNativeAdMarkup:(PBMNativeAdMarkup *)nativeAdMarkup
                           application:(id<PBMUIApplicationProtocol>)application
                    measurementWrapper:(PBMOpenMeasurementWrapper *)measurementWrapper
                      serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                      sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
{
    if (!(self = [super init])) {
        return nil;
    }
    _nativeAdMarkup = nativeAdMarkup;
    
    PBMExternalURLOpenerBlock const appUrlOpener = [PBMExternalURLOpeners applicationAsExternalUrlOpener:application];
    PBMTrackingURLVisitorBlock const trackingUrlVisitor = [PBMTrackingURLVisitors connectionAsTrackingURLVisitor:serverConnection];
    
    PBMExternalLinkHandler * const appUrlLinkHandler = [[PBMExternalLinkHandler alloc] initWithPrimaryUrlOpener:appUrlOpener
                                                                                              deepLinkUrlOpener:appUrlOpener
                                                                                             trackingUrlVisitor:trackingUrlVisitor];
    
    PBMModalManager * const modalManager = [[PBMModalManager alloc] initWithDelegate:nil];
    
    @weakify(self);
    
    PBMClickthroughBrowserOpener * const
    clickthroughOpener = [[PBMClickthroughBrowserOpener alloc] initWithSDKConfiguration:sdkConfiguration
                                                                        adConfiguration:nil
                                                                           modalManager:modalManager
                                                                 viewControllerProvider:^UIViewController * _Nullable{
        @strongify(self);
        id<PBMNativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(viewPresentationControllerForNativeAd:)]) {
            return [delegate viewPresentationControllerForNativeAd:self];
        } else {
            return nil;
        }
    } measurementSessionProvider: ^PBMOpenMeasurementSession * _Nullable{
        @strongify(self);
        return self.measurementSession;
    } onWillLoadURLInClickthrough:^{
        @strongify(self);
        id<PBMNativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdWillPresentModal:)]) {
            return [delegate nativeAdWillPresentModal:self];
        }
    } onWillLeaveAppBlock:^{
        @strongify(self);
        id<PBMNativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdWillLeaveApplication:)]) {
            return [delegate nativeAdWillLeaveApplication:self];
        }
    } onClickthroughPoppedBlock:^(PBMModalState * _Nonnull poppedState) {
        @strongify(self);
        id<PBMNativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdDidDismissModal:)]) {
            return [delegate nativeAdDidDismissModal:self];
        }
    } onDidLeaveAppBlock:^(PBMModalState * _Nonnull leavingState) {
        @strongify(self);
        id<PBMNativeAdUIDelegate> const delegate = self.uiDelegate;
        if ([delegate respondsToSelector:@selector(nativeAdWillLeaveApplication:)]) {
            return [delegate nativeAdWillLeaveApplication:self];
        }
    }];
    
    PBMExternalLinkHandler * const clickthroughLinkHandler = [appUrlLinkHandler handlerByAddingUrlOpenAttempter:clickthroughOpener.asUrlOpenAttempter];
    // TODO: Enable 'deeplink+' support
#   ifdef DEBUG
    // Note: keep unused variable to ensure the code compiles for later use
    PBMExternalLinkHandler * const deepLinkPlusHandler __attribute__((unused)) = [PBMDeepLinkPlusHelper deepLinkPlusHandlerWithExternalLinkHandler:clickthroughLinkHandler];
#   endif
    PBMExternalLinkHandler * const externalLinkHandler = clickthroughLinkHandler;
    
    _fireEventTrackersBlock = [PBMNativeAdImpressionReporting impressionReporterWithEventTrackers:nativeAdMarkup.eventtrackers
                                                                                       urlVisitor:trackingUrlVisitor];
    
    PBMVoidBlock const reportSelfClicked = ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        [self trackOMEvent:PBMTrackingEventClick];
        
        id<PBMNativeAdTrackingDelegate> const delegate = self.trackingDelegate;
        if (delegate && [delegate respondsToSelector:@selector(nativeAdDidLogClick:)]) {
            [delegate nativeAdDidLogClick:self];
        }
    };
    PBMNativeViewClickHandlerBlock const nativeClickHandler = ^(NSString *url,
                                                                NSString * _Nullable fallback,
                                                                NSArray<NSString *> * _Nullable clicktrackers,
                                                                PBMVoidBlock _Nullable onClickthroughExitBlock)
    {
        PBMVoidBlock const tryFallbackUrl = ^{
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
    
    PBMNativeClickTrackerBinderFactoryBlock const clickBinderFactory = [PBMNativeClickTrackerBinders smartBinder];
    
    _clickableViewRegistry = [[PBMNativeClickableViewRegistry alloc] initWithBinderFactory:clickBinderFactory
                                                                              clickHandler:nativeClickHandler];
    
    _measurementWrapper = measurementWrapper;
    
    return self;
}

// MARK: - NSObject

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    PBMNativeAd *other = object;
    return (self == other) || [self.nativeAdMarkup isEqual:other.nativeAdMarkup];
}

// MARK: - Public API (Root properties)

- (NSString *)version {
    return self.nativeAdMarkup.version ?: @"";
}

// MARK: - Public API (Convenience getters)

- (NSString *)title {
    NSArray<PBMNativeAdTitle *> * const titles = self.titles;
    NSString * const title = (titles.count > 0) ? titles[0].text : nil;
    return title ?: @"";
}

- (NSString *)text {
    NSArray<PBMNativeAdData *> * const descriptions = [self dataObjectsOfType:PBMDataAssetType_Desc];
    NSString * const description = (descriptions.count > 0) ? descriptions[0].value : nil;
    return description ?: @"";
}

- (NSString *)iconURL {
    NSArray<PBMNativeAdImage *> * const icons = [self imagesOfType:PBMImageAssetType_Icon];
    NSString * const icon = (icons.count > 0) ? icons[0].url : nil;
    return icon ?: @"";
}

- (NSString *)imageURL {
    NSArray<PBMNativeAdImage *> * const images = [self imagesOfType:PBMImageAssetType_Main];
    NSString * const image = (images.count > 0) ? images[0].url : nil;
    return image ?: @"";
}

- (nullable PBMNativeAdVideo *)videoAd {
    NSArray<PBMNativeAdVideo *> * const videoAds = self.videoAds;
    if (videoAds.count > 0) {
        return videoAds[0];
    } else {
        return nil;
    }
}

- (NSString *)callToAction {
    NSArray<PBMNativeAdData *> * const callToActions = [self dataObjectsOfType:PBMDataAssetType_CTAText];
    NSString * const callToAction = (callToActions.count > 0) ? callToActions[0].value : nil;
    return callToAction ?: @"";
}

// MARK: - Public API (Array getters)

- (NSArray<PBMNativeAdTitle *> *)titles {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<PBMNativeAdTitle *> * const result = [[NSMutableArray alloc] init];
    for (PBMNativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        PBMNativeAdTitle * const nextTitle = [[PBMNativeAdTitle alloc] initWithNativeAdMarkupAsset:nextAsset error:nil];
        if (nextTitle) {
            [result addObject:nextTitle];
        }
    }
    return result;
}

- (NSArray<PBMNativeAdData *> *)dataObjects {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<PBMNativeAdData *> * const result = [[NSMutableArray alloc] init];
    for (PBMNativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        PBMNativeAdData * const nextData = [[PBMNativeAdData alloc] initWithNativeAdMarkupAsset:nextAsset error:nil];
        if (nextData) {
            [result addObject:nextData];
        }
    }
    return result;
}

- (NSArray<PBMNativeAdImage *> *)images {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<PBMNativeAdImage *> * const result = [[NSMutableArray alloc] init];
    for (PBMNativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        PBMNativeAdImage * const nextImage = [[PBMNativeAdImage alloc] initWithNativeAdMarkupAsset:nextAsset error:nil];
        if (nextImage) {
            [result addObject:nextImage];
        }
    }
    return result;
}

- (NSArray<PBMNativeAdVideo *> *)videoAds {
    if (!self.nativeAdMarkup.assets) {
        return @[];
    }
    NSMutableArray<PBMNativeAdVideo *> * const result = [[NSMutableArray alloc] init];
    @weakify(self);
    PBMViewControllerProvider const viewControllerProvider = ^UIViewController * _Nullable{
        @strongify(self);
        return [self.uiDelegate viewPresentationControllerForNativeAd:self];
    };
    PBMNativeViewClickHandlerBlock const nativeClickHandler = self.nativeClickHandlerBlock;
    for (PBMNativeAdMarkupAsset *nextAsset in self.nativeAdMarkup.assets) {
        PBMNativeAdMarkupLink * const markupLink = nextAsset.link ?: self.nativeAdMarkup.link;
        PBMCreativeClickHandlerBlock const clickHandlerOverride = ((markupLink == nil)
                                                                   ? nil
                                                                   : ^(PBMVoidBlock  _Nonnull onClickthroughExitBlock) {
            nativeClickHandler(markupLink.url, markupLink.fallback, markupLink.clicktrackers, onClickthroughExitBlock);
        });
        PBMNativeAdMediaHooks * const
        nativeAdHooks = [[PBMNativeAdMediaHooks alloc] initWithViewControllerProvider:viewControllerProvider
                                                                 clickHandlerOverride:clickHandlerOverride];
        PBMNativeAdVideo * const nextVideo = [[PBMNativeAdVideo alloc] initWithNativeAdMarkupAsset:nextAsset
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

- (NSArray<PBMNativeAdData *> *)dataObjectsOfType:(PBMDataAssetType)dataType {
    NSMutableArray<PBMNativeAdData *> * const result = [[NSMutableArray alloc] init];
    for (PBMNativeAdData *nextData in self.dataObjects) {
        if (nextData.dataType.integerValue == dataType) {
            [result addObject:nextData];
        }
    }
    return result;
}

- (NSArray<PBMNativeAdImage *> *)imagesOfType:(PBMImageAssetType)imageType {
    NSMutableArray<PBMNativeAdImage *> * const result = [[NSMutableArray alloc] init];
    for (PBMNativeAdImage *nextImage in self.images) {
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
    self.impressionTracker = [[PBMNativeImpressionsTracker alloc] initWithView:adView
                                                               pollingInterval:VIEWABILITY_POLLING_INTERVAL
                                                         scheduledTimerFactory:[NSTimer pbmScheduledTimerFactory]
                                                    impressionDetectionHandler:^(PBMNativeEventType impressionType) {
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        if (impressionType == PBMNativeEventType_Impression) {
            [self trackOMEvent:PBMTrackingEventImpression];
        }
        
        self.fireEventTrackersBlock(impressionType);
        id<PBMNativeAdTrackingDelegate> const delegate = self.trackingDelegate;
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

- (void)registerClickView:(UIView *)adView nativeAdElementType:(PBMNativeAdElementType)nativeAdElementType {
    PBMNativeAdAsset * const relevantAsset = [self findAssetForElementType:nativeAdElementType];
    [self registerClickView:adView nativeAdAsset:relevantAsset];
}

- (void)registerClickView:(UIView *)adView nativeAdAsset:(PBMNativeAdAsset *)nativeAdAsset {
    PBMNativeAdMarkupLink * const relevantLink = nativeAdAsset.link ?: self.nativeAdMarkup.link;
    [self.clickableViewRegistry registerLink:relevantLink forView:adView];
}

// MARK: - Private Helpers

- (nullable PBMNativeAdAsset *)findAssetForElementType:(PBMNativeAdElementType)nativeAdElementType {
    NSArray<PBMNativeAdAsset *> *assets = nil;
    switch (nativeAdElementType) {
        case PBMNativeAdElementType_Title:
            assets = self.titles;
            break;
        case PBMNativeAdElementType_Text:
            assets = [self dataObjectsOfType:PBMDataAssetType_Desc];
            break;
        case PBMNativeAdElementType_Icon:
            assets = [self imagesOfType:PBMImageAssetType_Icon];
            break;
        case PBMNativeAdElementType_Image:
            assets = [self imagesOfType:PBMImageAssetType_Main];
            break;
        case PBMNativeAdElementType_VideoAd:
            assets = self.videoAds;
            break;
        case PBMNativeAdElementType_CallToAction:
            assets = [self dataObjectsOfType:PBMDataAssetType_CTAText];
            break;
        default:
            return nil;
    }
    return (assets.count > 0) ? assets[0] : nil;
}

// MARK: - Private Helpers (OpenMeasurement support)

- (void)createOpenMeasurementSession:(UIView *)adView {
    if (!NSThread.currentThread.isMainThread) {
        PBMLogError(@"Open Measurement session can only be created on the main thread");
        return;
    }
    
    PBMNativeAdMarkupEventTracker *omTracker = [self findOMIDTracker];
    
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

- (nullable PBMNativeAdMarkupEventTracker *)findOMIDTracker {
    for(PBMNativeAdMarkupEventTracker *omTracker in self.nativeAdMarkup.eventtrackers) {
        if (omTracker.event == PBMNativeEventType_OMID &&
            omTracker.method == PBMNativeEventTrackingMethod_JS &&
            omTracker.url) {
            return omTracker;
        }
    }
    return nil;
}

- (void)trackOMEvent:(PBMTrackingEvent) event {
    if (!self.measurementSession) {
        PBMLogError(@"Measurement Session is missed.");
        return;
    }
    
    if (event == PBMTrackingEventImpression) {
        [self.measurementSession.eventTracker trackEvent:PBMTrackingEventLoaded];
    }
    
    [self.measurementSession.eventTracker trackEvent:event];
}

@end
