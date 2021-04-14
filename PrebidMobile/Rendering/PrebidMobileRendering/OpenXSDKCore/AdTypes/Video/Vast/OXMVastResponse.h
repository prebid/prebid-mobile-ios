//
//  OXMVastResponse.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//This class is analogous to the <VAST> tag at the root of a Vast XML doc.

#import <Foundation/Foundation.h>

@class OXMVastAbstractAd;

@interface OXMVastResponse : NSObject

//TODO: Refactor OXMVastResponse.nextResponse and OXMVastWrapper.vastResponse together.

@property (nonatomic, strong, nullable) OXMVastResponse *nextResponse;
@property (nonatomic, weak, nullable) OXMVastResponse *parentResponse   NS_SWIFT_NAME(parentResponse);
@property (nonatomic, copy, nullable) NSString *noAdsResponseURI;
@property (nonatomic, strong, nonnull) NSMutableArray<OXMVastAbstractAd *> *vastAbstractAds; // TODO: should be readonly
@property (nonatomic, copy, nullable) NSString *version;

- (nullable NSArray<OXMVastAbstractAd *> *)flattenResponseAndReturnError:(NSError * __nullable * __null_unspecified)error;

@end
