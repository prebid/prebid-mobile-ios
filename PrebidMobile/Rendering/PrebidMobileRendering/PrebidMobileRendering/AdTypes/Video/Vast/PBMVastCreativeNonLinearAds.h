//
//  PBMVastCreativeNonLinearAds.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeAbstract.h"
#import "PBMVastCreativeNonLinearAdsNonLinear.h"

@interface PBMVastCreativeNonLinearAds : PBMVastCreativeAbstract <PBMVastResourceContainerProtocol>

@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastCreativeNonLinearAdsNonLinear *> *nonLinears;

// PBMVastResourceContainer
@property (nonatomic, assign) PBMVastResourceType resourceType;
@property (nonatomic, copy, nullable) NSString *resource;
@property (nonatomic, copy, nullable) NSString *staticType;

-(void)copyTracking:(nonnull PBMVastCreativeNonLinearAds *)fromNonLinearAds    NS_SWIFT_NAME(copyTracking(fromNonLinearAds:));

@end
