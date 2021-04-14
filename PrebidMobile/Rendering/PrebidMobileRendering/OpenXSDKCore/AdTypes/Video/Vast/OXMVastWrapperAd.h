//
//  OXMVastWrapperAd.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastAbstractAd.h"

@interface OXMVastWrapperAd : OXMVastAbstractAd

@property (nonatomic, copy, nullable) NSString *vastURI;   // the location of the next VAST tag
@property (nonatomic, strong, nullable) OXMVastResponse *vastResponse;
@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, assign) BOOL followAdditionalWrappers;
@property (nonatomic, assign) BOOL allowMultipleAds;
@property (nonatomic, assign) BOOL fallbackOnNoAd;

@end
