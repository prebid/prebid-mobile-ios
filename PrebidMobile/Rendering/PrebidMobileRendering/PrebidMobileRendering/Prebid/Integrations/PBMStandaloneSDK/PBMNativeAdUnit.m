//
//  PBMNativeAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdUnit.h"
#import "PBMBaseAdUnit+Protected.h"
#import "PBMNativeAdUnit+Testing.h"

#import "PBMBidRequesterFactory.h"
#import "PBMDemandResponseInfo+Internal.h"
#import "PBMSDKConfiguration.h"
#import "PBMTargeting.h"
#import "PBMWinNotifier.h"
#import "PBMServerConnection.h"

#import "PBMMacros.h"

@interface PBMNativeAdUnit ()
@property (nonatomic, assign) BOOL hasStartedFetching;
@end


@implementation PBMNativeAdUnit

// MARK: - Lifecycle

// MARK: + (public convenience init)
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration
{
    return (self = [self initWithConfigID:configID
                    nativeAdConfiguration:nativeAdConfiguration
                         serverConnection:[PBMServerConnection singleton]
                         sdkConfiguration:[PBMSDKConfiguration singleton]
                                targeting:[PBMTargeting shared]]);
}

// MARK: + (private convenience init)
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration
                serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration
                       targeting:(PBMTargeting *)targeting
{
    return (self = [self initWithConfigID:configID
                    nativeAdConfiguration:nativeAdConfiguration
                      bidRequesterFactory:[PBMBidRequesterFactory requesterFactoryWithConnection:serverConnection
                                                                                sdkConfiguration:sdkConfiguration
                                                                                       targeting:targeting]
                         winNotifierBlock:[PBMWinNotifier winNotifierBlockWithConnection:serverConnection]]);
}

// MARK: + (private designated init)
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration
             bidRequesterFactory:(PBMBidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock
{
    if (!(self = [super initWithConfigID:configID
                     bidRequesterFactory:bidRequesterFactory
                        winNotifierBlock:winNotifierBlock]))
    {
        return nil;
    }
    
    //NOTE: At the moment (10 March 2021) PBS doesn't support OM event trackers:
    //https://github.com/prebid/prebid-server/issues/1732
    //Remove the next line
    self.adUnitConfig.nativeAdConfig = nativeAdConfiguration;
    //and uncomment the next one when PBS be ready
    //[self setupNativeAdConfiguration:nativeAdConfiguration];
    return self;
}

// MARK: - Computed public properties

- (NSString *)configId {
    return [super configId];
}

- (PBMNativeAdConfiguration *)nativeAdConfig {
    return self.adUnitConfig.nativeAdConfig;
}

// MARK: - Get Native Ad

- (void)fetchDemandWithCompletion:(PBMFetchDemandCompletionHandler)completion {
    @synchronized (self.stateLockToken) {
        if (self.hasStartedFetching) {
            PBMFetchDemandResult const demandResult = PBMFetchDemandResult_SDKMisuse_NativeAdUnitFetchedAgain;
            completion([[PBMDemandResponseInfo alloc] initWithFetchDemandResult:demandResult
                                                                            bid:nil
                                                                       configId:nil
                                                               winNotifierBlock:self.winNotifierBlock]);
            return;
        }
        self.hasStartedFetching = YES;
    }
    [super fetchDemandWithCompletion:completion];
}

// MARK: - Private methods
- (void)setupNativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration {
    PBMNativeAdConfiguration * const nativeAdConfig = [nativeAdConfiguration copy];
    
    NSArray<PBMNativeEventTracker *> *existingTrackers = nativeAdConfig.eventtrackers;
    NSMutableArray<PBMNativeEventTracker *> *eventtrackers = existingTrackers ? [existingTrackers mutableCopy] : [[NSMutableArray<PBMNativeEventTracker *> alloc] init];
    PBMNativeEventTracker *omidEventTracker = [[PBMNativeEventTracker alloc] initWithEvent:PBMNativeEventType_OMID
                                                                                   methods:@[@(PBMNativeEventTrackingMethod_JS)]];
    [eventtrackers addObject:omidEventTracker];
    //TODO: add additional Apollo event trackers?
    nativeAdConfig.eventtrackers = eventtrackers;
    
    self.adUnitConfig.nativeAdConfig = nativeAdConfig;
}

@end
