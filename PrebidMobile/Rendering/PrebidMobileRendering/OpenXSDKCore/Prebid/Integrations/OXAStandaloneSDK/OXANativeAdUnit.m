//
//  OXANativeAdUnit.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdUnit.h"
#import "OXABaseAdUnit+Protected.h"
#import "OXANativeAdUnit+Testing.h"

#import "OXABidRequesterFactory.h"
#import "OXADemandResponseInfo+Internal.h"
#import "OXASDKConfiguration.h"
#import "OXATargeting.h"
#import "OXAWinNotifier.h"
#import "OXMServerConnection.h"

#import "OXMMacros.h"

@interface OXANativeAdUnit ()
@property (nonatomic, assign) BOOL hasStartedFetching;
@end


@implementation OXANativeAdUnit

// MARK: - Lifecycle

// MARK: + (public convenience init)
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration
{
    return (self = [self initWithConfigID:configID
                    nativeAdConfiguration:nativeAdConfiguration
                         serverConnection:[OXMServerConnection singleton]
                         sdkConfiguration:[OXASDKConfiguration singleton]
                                targeting:[OXATargeting shared]]);
}

// MARK: + (private convenience init)
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration
                serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                       targeting:(OXATargeting *)targeting
{
    return (self = [self initWithConfigID:configID
                    nativeAdConfiguration:nativeAdConfiguration
                      bidRequesterFactory:[OXABidRequesterFactory requesterFactoryWithConnection:serverConnection
                                                                                sdkConfiguration:sdkConfiguration
                                                                                       targeting:targeting]
                         winNotifierBlock:[OXAWinNotifier winNotifierBlockWithConnection:serverConnection]]);
}

// MARK: + (private designated init)
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration
             bidRequesterFactory:(OXABidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(OXAWinNotifierBlock)winNotifierBlock
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

- (OXANativeAdConfiguration *)nativeAdConfig {
    return self.adUnitConfig.nativeAdConfig;
}

// MARK: - Get Native Ad

- (void)fetchDemandWithCompletion:(OXAFetchDemandCompletionHandler)completion {
    @synchronized (self.stateLockToken) {
        if (self.hasStartedFetching) {
            OXAFetchDemandResult const demandResult = OXAFetchDemandResult_SDKMisuse_NativeAdUnitFetchedAgain;
            completion([[OXADemandResponseInfo alloc] initWithFetchDemandResult:demandResult
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
- (void)setupNativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration {
    OXANativeAdConfiguration * const nativeAdConfig = [nativeAdConfiguration copy];
    
    NSArray<OXANativeEventTracker *> *existingTrackers = nativeAdConfig.eventtrackers;
    NSMutableArray<OXANativeEventTracker *> *eventtrackers = existingTrackers ? [existingTrackers mutableCopy] : [[NSMutableArray<OXANativeEventTracker *> alloc] init];
    OXANativeEventTracker *omidEventTracker = [[OXANativeEventTracker alloc] initWithEvent:OXANativeEventType_OMID
                                                                                   methods:@[@(OXANativeEventTrackingMethod_JS)]];
    [eventtrackers addObject:omidEventTracker];
    //TODO: add additional Apollo event trackers?
    nativeAdConfig.eventtrackers = eventtrackers;
    
    self.adUnitConfig.nativeAdConfig = nativeAdConfig;
}

@end
