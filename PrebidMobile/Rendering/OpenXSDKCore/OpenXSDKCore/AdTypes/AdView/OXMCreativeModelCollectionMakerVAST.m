//
//  OXMACJCreativeModelCollectionMaker.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMCreativeModelCollectionMakerVAST.h"
#import "OXMVastCreativeCompanionAdsCompanion.h"
#import "OXMCreativeModel.h"
#import "OXMServerResponse.h"
#import "OXMTrackingEvent.h"
#import "OXMAdConfiguration.h"
#import "OXMVastCreativeLinear.h"
#import "OXMVastInlineAd.h"
#import "OXMVastParser.h"
#import "OXMVastResponse.h"
#import "OXMAdRequestResponseVAST.h"
#import "OXMVastCreativeCompanionAds.h"
#import "OXMFunctions+Private.h"
#import "OXMError.h"
#import "OXMAdModelEventTracker.h"


@implementation OXMCreativeModelCollectionMakerVAST

- (instancetype)initWithServerConnection:(id<OXMServerConnectionProtocol>)oxmServerConnection
                            adConfiguration:(OXMAdConfiguration *)adConfiguration {
    self = [super init];
    if (self) {
        self.adConfiguration = adConfiguration;
        self.serverConnection = oxmServerConnection;
    }
    
    return self;
}

- (void)makeModels:(OXMAdRequestResponseVAST *) adRequestResponse
   successCallback:(OXMCreativeModelMakerSuccessCallback) successCallback
   failureCallback:(OXMCreativeModelMakerFailureCallback)failureCallback {
    
    OXMAdRequestResponseVAST *vastResponse = (OXMAdRequestResponseVAST*) adRequestResponse;
    
    NSError* error = nil;
    NSArray<OXMCreativeModel *> *models = [self createCreativeModelsFromResponse:vastResponse.ads error:&error];

    if (error) {
        failureCallback(error);
    }
    
    successCallback(models);
}

#pragma mark - Internal Methods


- (NSArray<OXMCreativeModel *> *)createCreativeModelsFromResponse:(NSArray<OXMVastAbstractAd *> *)ads
                                                            error:(NSError **)error {
    NSString *errorMessage = @"No creative";
    NSMutableArray <OXMCreativeModel *> *creatives = [NSMutableArray <OXMCreativeModel *> new];
    OXMVastInlineAd *vastAd = (OXMVastInlineAd *)ads.firstObject;
    
    if (vastAd.creatives == nil || vastAd.creatives.count == 0) {
        [OXMError createError:error description:errorMessage statusCode:OXAErrorCodeGeneralLinear];
        return nil;
    }
    
    // Create the Linear Creative Model
    OXMVastCreativeLinear *creative = (OXMVastCreativeLinear*)vastAd.creatives.firstObject;
    if (creative == nil) {
        [OXMError createError:error description:errorMessage statusCode:OXAErrorCodeGeneralLinear];
        return nil;
    }
    
    OXMVastMediaFile *bestMediaFile = [creative bestMediaFile];
    if (bestMediaFile == nil) {
        errorMessage = @"No suitable media file";
        [OXMError createError:error description:errorMessage statusCode:OXAErrorCodeFileNotFound];
        return nil;
    }
    
    OXMCreativeModel *creativeModel = [self createCreativeModelWithAd:vastAd creative:creative mediaFile:bestMediaFile];
    if (creativeModel == nil) {
        errorMessage = @"Error creating CreativeModel";
        [OXMError createError:error description:errorMessage statusCode:OXAErrorCodeUndefined];
        return nil;
    }
    [creatives addObject:creativeModel];
    
    // Creative the Companion Ads creative model
    // Per the Vast spec, we have either 1 Linear or NonLinear, the rest are the companion ads/end cards.
    NSMutableArray<OXMVastCreativeCompanionAds *> *companionItems = [NSMutableArray<OXMVastCreativeCompanionAds *> new];
    for (OXMVastCreativeCompanionAds* item in vastAd.creatives) {
        if ([item isKindOfClass:[OXMVastCreativeCompanionAds class]]) {
            [companionItems addObject:item];
        }
    }
    
    if (companionItems.count > 0) {
        // There is at least 1 companion.  Set the flag so that when the initial video creative has completed
        // display, the appropriate view controllers will prevent the "close" button and the learn more after the video has
        // finished, it will instead display the endcard.
        creativeModel.hasCompanionAd = YES;
        
        // Now try to create the companion items creatives.
        // Create a model of the best fitting companion ad.
        OXMCreativeModel *creativeModelCompanion = [self createCompanionCreativeModelWithAd:vastAd
                                                                               companionAds:companionItems
                                                                                   creative:creative];
        if (creativeModelCompanion) {
            [creatives addObject:creativeModelCompanion];
        }
    }
    
    return creatives;
}

- (OXMCreativeModel *)createCreativeModelWithAd:(OXMVastInlineAd *)vastAd
                                       creative:(OXMVastCreativeLinear *)creative
                                      mediaFile:(OXMVastMediaFile *)mediaFile {
   
    OXMCreativeModel *creativeModel = [[OXMCreativeModel alloc] initWithAdConfiguration:self.adConfiguration];
    creativeModel.eventTracker = [[OXMAdModelEventTracker alloc] initWithCreativeModel:creativeModel serverConnection:self.serverConnection];
    creativeModel.verificationParameters = vastAd.verificationParameters;

    //Pack successful data into a CreativeModel
    creativeModel.videoFileURL = mediaFile.mediaURI;
    creativeModel.displayDurationInSeconds = [NSNumber numberWithDouble: creative.duration];
    creativeModel.skipOffset = creative.skipOffset;
    creativeModel.width = mediaFile.width;
    creativeModel.height = mediaFile.height;
    
    NSMutableDictionary *trackingURLs = [creative.vastTrackingEvents.trackingEvents mutableCopy];
    
    // Store the impression URIs so that can be fired at the appropriate time.
    NSString *impressionKey = [OXMTrackingEventDescription getDescription:OXMTrackingEventImpression];
    trackingURLs[impressionKey] = vastAd.impressionURIs;
    NSString *clickKey = [OXMTrackingEventDescription getDescription:OXMTrackingEventClick];
    trackingURLs[clickKey] = creative.clickTrackingURIs;
    
    creativeModel.trackingURLs = trackingURLs;
    creativeModel.clickThroughURL = creative.clickThroughURI;
    
    return creativeModel;
}

- (OXMCreativeModel *)createCompanionCreativeModelWithAd:(OXMVastInlineAd *)vastAd
                                            companionAds:(NSArray<OXMVastCreativeCompanionAds *>*)companionAds
                                                creative:(OXMVastCreativeLinear *)creative {
    if ((companionAds == nil) || (creative == nil)) {
        return nil;
    }
    
    if (companionAds.count == 0) {
        return nil;
    }
    
    // LEGACY: Sounds weird. Need to use the same ad configuration
    // Create a new config using it's default: OXMAdFormat = OXMAdFormatDisplay
    OXMAdConfiguration *adConfiguration = [[OXMAdConfiguration alloc] init];
    
    adConfiguration.isInterstitialAd = YES;
    adConfiguration.isOptIn = YES;
    adConfiguration.isBuiltInVideo = self.adConfiguration.isBuiltInVideo;
    adConfiguration.clickHandlerOverride = self.adConfiguration.clickHandlerOverride;
    
    OXMCreativeModel *creativeModel = [[OXMCreativeModel alloc] initWithAdConfiguration:adConfiguration];
    creativeModel.eventTracker = [[OXMAdModelEventTracker alloc] initWithCreativeModel:creativeModel serverConnection:self.serverConnection];
    creativeModel.verificationParameters = vastAd.verificationParameters;

    OXMVastCreativeCompanionAds* companionAd = [companionAds firstObject];
    if (companionAd.companions.count == 0) {
        return nil;
    }
    
    // get the most appropriate companion from the list.
    OXMVastCreativeCompanionAdsCompanion* companion = [self getMostAppropriateCompanion: companionAd];
    if (companion == nil) {
        return nil;
    }
    NSString* resource;
    switch (companion.resourceType) {
        case OXMVastResourceTypeStaticResource:
            // image. build html around resource
            resource = [self buildStaticResource:companion];
            break;
        case OXMVastResourceTypeIFrameResource:
            resource = companion.resource;
            break;
        case OXMVastResourceTypeHtmlResource:
            resource = companion.resource;
            break;
        default:
            // unrecognized companion type.
            return nil;
    }
    
    if (!resource) {
        return nil;
    }

    creativeModel.html = resource;
    creativeModel.width = companion.width;
    creativeModel.height = companion.height;
    creativeModel.clickThroughURL = companion.clickThroughURI;
    
    // Store the impression URIs so that can be fired at the appropriate time.
    NSMutableDictionary *trackingURLs = [companion.trackingEvents.trackingEvents mutableCopy];
    NSString *companionClickKey = [OXMTrackingEventDescription getDescription:OXMTrackingEventCompanionClick];

    NSMutableArray *trackingArray = trackingURLs[companionClickKey];
    // Create a companion array if it doesn't already exist.
    if (trackingURLs[companionClickKey] == nil) {
        trackingArray = [NSMutableArray new];
    }
    // Save the the tracking urls in the array.
    trackingURLs[companionClickKey] = [trackingArray arrayByAddingObjectsFromArray:companion.clickTrackingURIs];
    
    NSString *clickKey = [OXMTrackingEventDescription getDescription:OXMTrackingEventClick];
    trackingURLs[clickKey] = companion.clickTrackingURIs;

    creativeModel.trackingURLs = trackingURLs;

    // tag this creative model as an end card.
    creativeModel.isCompanionAd = YES;
    return creativeModel;
 }

- (OXMVastCreativeCompanionAdsCompanion*) getMostAppropriateCompanion: (OXMVastCreativeCompanionAds*) companionAd {
    // currently we only return the first option.
    // Todo: add additional logic for the most appropriate using the following:
    //  * size
    //  * type
    OXMVastCreativeCompanionAdsCompanion* companion;

    companion = [companionAd.companions firstObject];
    return companion;
}

- (NSString*) buildStaticResource: (OXMVastCreativeCompanionAdsCompanion*)companion {
    if (companion == nil) {
        return nil;
    }
    NSBundle * sdkBundle = [OXMFunctions bundleForSDK];
    if (sdkBundle == nil) {
        return nil;
    }
    NSString *path = [sdkBundle pathForResource:@"companion" ofType:@"html"];
    if (!path) {
        // error reading html
        return nil;
    }
    
    NSString *templateHtmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!templateHtmlString) {
        return nil;
    }
    
    NSString * html = [NSString stringWithFormat:templateHtmlString, companion.clickThroughURI, companion.resource];
    return html;
}

@end
