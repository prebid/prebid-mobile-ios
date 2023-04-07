/*   Copyright 2018-2021 Prebid.org, Inc.

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

#import "PBMCreativeModelCollectionMakerVAST.h"
#import "PBMVastCreativeCompanionAdsCompanion.h"
#import "PBMCreativeModel.h"
#import "PBMTrackingEvent.h"
#import "PBMVastCreativeLinear.h"
#import "PBMVastInlineAd.h"
#import "PBMVastParser.h"
#import "PBMVastResponse.h"
#import "PBMAdRequestResponseVAST.h"
#import "PBMVastCreativeCompanionAds.h"
#import "PBMFunctions+Private.h"
#import "PBMError.h"
#import "PBMAdModelEventTracker.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif


@implementation PBMCreativeModelCollectionMakerVAST

- (instancetype)initWithServerConnection:(id<PrebidServerConnectionProtocol>)serverConnection
                            adConfiguration:(PBMAdConfiguration *)adConfiguration {
    self = [super init];
    if (self) {
        self.adConfiguration = adConfiguration;
        self.serverConnection = serverConnection;
    }
    
    return self;
}

- (void)makeModels:(PBMAdRequestResponseVAST *) adRequestResponse
   successCallback:(PBMCreativeModelMakerSuccessCallback) successCallback
   failureCallback:(PBMCreativeModelMakerFailureCallback)failureCallback {
    
    PBMAdRequestResponseVAST *vastResponse = (PBMAdRequestResponseVAST*) adRequestResponse;
    
    NSError* error = nil;
    NSArray<PBMCreativeModel *> *models = [self createCreativeModelsFromResponse:vastResponse.ads error:&error];

    if (error) {
        failureCallback(error);
        return;
    }
    
    successCallback(models);
}

#pragma mark - Internal Methods


- (NSArray<PBMCreativeModel *> *)createCreativeModelsFromResponse:(NSArray<PBMVastAbstractAd *> *)ads
                                                            error:(NSError **)error {
    NSString *errorMessage = @"No creative";
    NSMutableArray <PBMCreativeModel *> *creatives = [NSMutableArray <PBMCreativeModel *> new];
    PBMVastInlineAd *vastAd = (PBMVastInlineAd *)ads.firstObject;
    
    if (vastAd.creatives == nil || vastAd.creatives.count == 0) {
        [PBMError createError:error description:errorMessage statusCode:PBMErrorCodeGeneralLinear];
        return nil;
    }
    
    // Create the Linear Creative Model
    PBMVastCreativeLinear *creative = (PBMVastCreativeLinear*)vastAd.creatives.firstObject;
    if (creative == nil) {
        [PBMError createError:error description:errorMessage statusCode:PBMErrorCodeGeneralLinear];
        return nil;
    }
    
    PBMVastMediaFile *bestMediaFile = [creative bestMediaFile];
    if (bestMediaFile == nil) {
        errorMessage = @"No suitable media file";
        [PBMError createError:error description:errorMessage statusCode:PBMErrorCodeFileNotFound];
        return nil;
    }
    
    PBMCreativeModel *creativeModel = [self createCreativeModelWithAd:vastAd creative:creative mediaFile:bestMediaFile error:error];
    if (creativeModel == nil) {
        return nil;
    }

    [creatives addObject:creativeModel];
    
    // Creative the Companion Ads creative model
    // Per the Vast spec, we have either 1 Linear or NonLinear, the rest are the companion ads/end cards.
    NSMutableArray<PBMVastCreativeCompanionAds *> *companionItems = [NSMutableArray<PBMVastCreativeCompanionAds *> new];
    for (PBMVastCreativeCompanionAds* item in vastAd.creatives) {
        if ([item isKindOfClass:[PBMVastCreativeCompanionAds class]]) {
            [companionItems addObject:item];
        }
    }
    
    if (companionItems.count > 0) {
        // Now try to create the companion items creatives.
        // Create a model of the best fitting companion ad.
        PBMCreativeModel *creativeModelCompanion = [self createCompanionCreativeModelWithAd:vastAd
                                                                               companionAds:companionItems
                                                                                   creative:creative];
        if (creativeModelCompanion) {
            // There is at least 1 companion.  Set the flag so that when the initial video creative has completed
            // display, the appropriate view controllers will prevent the "close" button and the learn more after the video has
            // finished, it will instead display the endcard.
            creativeModel.hasCompanionAd = YES;
            [creatives addObject:creativeModelCompanion];
        }
    }
    
    return creatives;
}

- (PBMCreativeModel *)createCreativeModelWithAd:(PBMVastInlineAd *)vastAd
                                       creative:(PBMVastCreativeLinear *)creative
                                      mediaFile:(PBMVastMediaFile *)mediaFile
                                          error:(NSError **)error {

    if (!creative.duration || creative.duration <= 0) {
        NSString *errorMessage = @"Creative duration is invalid";
        [PBMError createError:error description:errorMessage statusCode:PBMErrorCodeGeneral];
        return nil;
    }
    
    if (self.adConfiguration.videoControlsConfig.maxVideoDuration && creative.duration > self.adConfiguration.videoControlsConfig.maxVideoDuration.doubleValue) {
        NSString *errorMessage = @"Creative duration is bigger than maximum available playback time obtained from server response.";
        [PBMError createError:error description:errorMessage statusCode:PBMErrorCodeGeneral];
        return nil;
    } else if (self.adConfiguration.videoParameters.maxDuration.value && creative.duration > self.adConfiguration.videoParameters.maxDuration.value) {
        NSString *errorMessage = @"Creative duration is bigger than maximum available playback time set by the user.";
        [PBMError createError:error description:errorMessage statusCode:PBMErrorCodeGeneral];
        return nil;
    }

    PBMCreativeModel *creativeModel = [[PBMCreativeModel alloc] initWithAdConfiguration:self.adConfiguration];
    creativeModel.eventTracker = [[PBMAdModelEventTracker alloc] initWithCreativeModel:creativeModel serverConnection:self.serverConnection];
    creativeModel.verificationParameters = vastAd.verificationParameters;

    //Pack successful data into a CreativeModel
    creativeModel.videoFileURL = mediaFile.mediaURI;
    creativeModel.displayDurationInSeconds = [NSNumber numberWithDouble: creative.duration];
    creativeModel.skipOffset = creative.skipOffset;
    creativeModel.width = mediaFile.width;
    creativeModel.height = mediaFile.height;
    
    NSMutableDictionary *trackingURLs = [creative.vastTrackingEvents.trackingEvents mutableCopy];
    
    // Store the impression URIs so that can be fired at the appropriate time.
    NSString *impressionKey = [PBMTrackingEventDescription getDescription:PBMTrackingEventImpression];
    trackingURLs[impressionKey] = vastAd.impressionURIs;
    NSString *clickKey = [PBMTrackingEventDescription getDescription:PBMTrackingEventClick];
    trackingURLs[clickKey] = creative.clickTrackingURIs;
    
    creativeModel.trackingURLs = trackingURLs;
    creativeModel.clickThroughURL = creative.clickThroughURI;
    
    return creativeModel;
}

- (PBMCreativeModel *)createCompanionCreativeModelWithAd:(PBMVastInlineAd *)vastAd
                                            companionAds:(NSArray<PBMVastCreativeCompanionAds *>*)companionAds
                                                creative:(PBMVastCreativeLinear *)creative {
    if ((companionAds == nil) || (creative == nil)) {
        return nil;
    }
    
    if (companionAds.count == 0) {
        return nil;
    }
    
    PBMCreativeModel *creativeModel = [[PBMCreativeModel alloc] initWithAdConfiguration:self.adConfiguration];
    creativeModel.eventTracker = [[PBMAdModelEventTracker alloc] initWithCreativeModel:creativeModel serverConnection:self.serverConnection];
    creativeModel.verificationParameters = vastAd.verificationParameters;

    PBMVastCreativeCompanionAds* companionAd = [companionAds firstObject];
    if (companionAd.companions.count == 0) {
        return nil;
    }
    
    // get the most appropriate companion from the list.
    PBMVastCreativeCompanionAdsCompanion* companion = [self getMostAppropriateCompanion: companionAd];
    if (companion == nil) {
        return nil;
    }
    NSString* resource;
    switch (companion.resourceType) {
        case PBMVastResourceTypeStaticResource:
            // image. build html around resource
            resource = [self buildStaticResource:companion];
            break;
        case PBMVastResourceTypeIFrameResource:
            resource = companion.resource;
            break;
        case PBMVastResourceTypeHtmlResource:
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
    NSString *companionClickKey = [PBMTrackingEventDescription getDescription:PBMTrackingEventCompanionClick];

    NSMutableArray *trackingArray = trackingURLs[companionClickKey];
    // Create a companion array if it doesn't already exist.
    if (trackingURLs[companionClickKey] == nil) {
        trackingArray = [NSMutableArray new];
    }
    // Save the the tracking urls in the array.
    trackingURLs[companionClickKey] = [trackingArray arrayByAddingObjectsFromArray:companion.clickTrackingURIs];
    
    NSString *clickKey = [PBMTrackingEventDescription getDescription:PBMTrackingEventClick];
    trackingURLs[clickKey] = companion.clickTrackingURIs;

    creativeModel.trackingURLs = trackingURLs;

    // tag this creative model as an end card.
    creativeModel.isCompanionAd = YES;
    return creativeModel;
 }

- (PBMVastCreativeCompanionAdsCompanion*) getMostAppropriateCompanion: (PBMVastCreativeCompanionAds*) companionAd {
    // currently we only return the first option.
    // Todo: add additional logic for the most appropriate using the following:
    //  * size
    //  * type
    PBMVastCreativeCompanionAdsCompanion* companion;

    companion = [companionAd.companions firstObject];
    return companion;
}

- (NSString*) buildStaticResource: (PBMVastCreativeCompanionAdsCompanion*)companion {
    if (companion == nil) {
        return nil;
    }
    
    NSString * html = [NSString stringWithFormat:PrebidConstants.companionHTMLTemplate, companion.clickThroughURI, companion.resource];
    
    return html;
}

@end
