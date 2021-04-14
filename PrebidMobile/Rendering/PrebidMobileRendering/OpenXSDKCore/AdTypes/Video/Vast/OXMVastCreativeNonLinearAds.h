//
//  OXMVastCreativeNonLinearAds.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeAbstract.h"
#import "OXMVastCreativeNonLinearAdsNonLinear.h"

@interface OXMVastCreativeNonLinearAds : OXMVastCreativeAbstract <OXMVastResourceContainerProtocol>

@property (nonatomic, strong, nonnull) NSMutableArray<OXMVastCreativeNonLinearAdsNonLinear *> *nonLinears;

// OXMVastResourceContainer
@property (nonatomic, assign) OXMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

-(void)copyTracking:(nonnull OXMVastCreativeNonLinearAds *)fromNonLinearAds    NS_SWIFT_NAME(copyTracking(fromNonLinearAds:));

@end
