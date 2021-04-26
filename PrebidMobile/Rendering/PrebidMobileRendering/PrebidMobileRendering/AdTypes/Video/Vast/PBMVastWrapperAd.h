//
//  PBMVastWrapperAd.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastAbstractAd.h"

@interface PBMVastWrapperAd : PBMVastAbstractAd

@property (nonatomic, copy, nullable) NSString *vastURI;   // the location of the next VAST tag
@property (nonatomic, strong, nullable) PBMVastResponse *vastResponse;
@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, assign) BOOL followAdditionalWrappers;
@property (nonatomic, assign) BOOL allowMultipleAds;
@property (nonatomic, assign) BOOL fallbackOnNoAd;

@end
