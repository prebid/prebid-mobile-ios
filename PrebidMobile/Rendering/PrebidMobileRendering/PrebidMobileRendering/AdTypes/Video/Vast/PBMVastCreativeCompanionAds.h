//
//  PBMVastCreativeCompanionAds.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBMVastCreativeAbstract.h"
#import "PBMVastCreativeCompanionAdsCompanion.h"

//TODO: make sure that clickThroughURI and adParameters always return nil. Use Optionals.

@interface PBMVastCreativeCompanionAds : PBMVastCreativeAbstract

@property (nonatomic, strong, nonnull) NSMutableArray<PBMVastCreativeCompanionAdsCompanion *> *companions;
@property (nonatomic, copy, nonnull) NSString *requiredMode;

//Should this be public?
- (nonnull NSArray<PBMVastCreativeCompanionAdsCompanion *> *)feasibleCompanions;
- (BOOL)canPlayRequiredCompanions;
- (void)copyTracking:(nonnull PBMVastCreativeCompanionAds *)fromCompanionAds NS_SWIFT_NAME(copyTracking(fromCompanionAds:));

@end
