//
//  OXMVastCreativeCompanionAds.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMVastCreativeAbstract.h"
#import "OXMVastCreativeCompanionAdsCompanion.h"

//TODO: make sure that clickThroughURI and adParameters always return nil. Use Optionals.

@interface OXMVastCreativeCompanionAds : OXMVastCreativeAbstract

@property (nonatomic, strong, nonnull) NSMutableArray<OXMVastCreativeCompanionAdsCompanion *> *companions;
@property (nonatomic, copy, nonnull) NSString *requiredMode;

//Should this be public?
- (nonnull NSArray<OXMVastCreativeCompanionAdsCompanion *> *)feasibleCompanions;
- (BOOL)canPlayRequiredCompanions;
- (void)copyTracking:(nonnull OXMVastCreativeCompanionAds *)fromCompanionAds NS_SWIFT_NAME(copyTracking(fromCompanionAds:));

@end
