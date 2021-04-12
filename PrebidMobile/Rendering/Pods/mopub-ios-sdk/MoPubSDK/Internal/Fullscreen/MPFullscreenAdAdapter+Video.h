//
//  MPFullscreenAdAdapter+Video.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdDestinationDisplayAgent.h"
#import "MPFullscreenAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter (Video)

/**
 Parse the VAST XML and resolve potential wrapper chain, and then precache the media file if needed,
 and finally create the view controller with the media file automatially loaded into it.
 
 Note: `MPAdConfiguration.precacheRequired` is ignored because video precaching is always enforced
 for VAST. See MoPub documentation: https://developers.mopub.com/dsps/ad-formats/video/
 
 Prerequisite: `self.configuration` is not nil.
 */
- (void)fetchAndLoadVideoAd;

@end

#pragma mark -

@interface MPFullscreenAdAdapter (MPAdDestinationDisplayAgentDelegate) <MPAdDestinationDisplayAgentDelegate>
@end

NS_ASSUME_NONNULL_END
