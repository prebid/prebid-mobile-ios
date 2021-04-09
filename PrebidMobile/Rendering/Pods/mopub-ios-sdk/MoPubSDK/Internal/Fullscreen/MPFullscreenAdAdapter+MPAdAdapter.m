//
//  MPFullscreenAdAdapter+MPAdAdapter.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPError.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPLogging.h"

@implementation MPFullscreenAdAdapter (MPAdAdapter)

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration targeting:(MPAdTargeting *)targeting {
    MPLogInfo(@"Looking for adapter class named %@.", configuration.adapterClass);
    [self setUpWithAdConfiguration:configuration localExtras:targeting.localExtras];
    [self startTimeoutTimer];
    
    [self requestAdWithAdapterInfo:configuration.adapterClassData
                          adMarkup:configuration.advancedBidPayload];
}

- (void)showFullscreenAdFromViewController:(UIViewController *)viewController {
    [self presentAdFromViewController:viewController];
}

- (void)expireAdapter {
    [self.delegate fullscreenAdAdapterDidExpire:self];
}

@end
