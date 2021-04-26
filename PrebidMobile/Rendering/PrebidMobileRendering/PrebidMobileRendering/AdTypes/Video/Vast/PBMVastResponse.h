//
//  PBMVastResponse.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//This class is analogous to the <VAST> tag at the root of a Vast XML doc.

#import <Foundation/Foundation.h>

@class PBMVastAbstractAd;

@interface PBMVastResponse : NSObject

//TODO: Refactor PBMVastResponse.nextResponse and PBMVastWrapper.vastResponse together.

@property (nonatomic, strong, nullable) PBMVastResponse *nextResponse;
@property (nonatomic, weak, nullable) PBMVastResponse *parentResponse   NS_SWIFT_NAME(parentResponse);
@property (nonatomic, copy, nullable) NSString *noAdsResponseURI;
@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastAbstractAd *> *vastAbstractAds; // TODO: should be readonly
@property (nonatomic, copy, nullable) NSString *version;

- (nullable NSArray<PBMVastAbstractAd *> *)flattenResponseAndReturnError:(NSError * __nullable * __null_unspecified)error;

@end
