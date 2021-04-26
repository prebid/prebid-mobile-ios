//
//  PBMVastCreativeCompanionAds.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastCreativeCompanionAds.h"
#import "PBMVastGlobals.h"

#pragma mark - Private Extension

@interface PBMVastCreativeCompanionAds()

//TODO: Change to an internal var with a get
@property (nonatomic, strong, nullable) NSMutableArray<PBMVastCreativeCompanionAdsCompanion *> *myFeasibleCompanions;

@end

#pragma mark - Implementation

@implementation PBMVastCreativeCompanionAds

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.companions = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public

-(NSArray<PBMVastCreativeCompanionAdsCompanion *> *)feasibleCompanions {
    if (!self.myFeasibleCompanions) {
        self.myFeasibleCompanions = [NSMutableArray array];
        for (PBMVastCreativeCompanionAdsCompanion *companion in self.companions) {
            if (! (companion.resourceType == PBMVastResourceTypeStaticResource &&
                [companion.staticType isEqualToString:@"application/x-shockwave-flash"])) {
                CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                if ((CGFloat)companion.width < screenSize.width || (CGFloat)companion.height < screenSize.height) {
                    [self.myFeasibleCompanions addObject:companion];
                }
            }
        }
    }
    
    return self.myFeasibleCompanions;
}

-(BOOL)canPlayRequiredCompanions {
    BOOL ret = YES;
    if ([self.requiredMode isEqualToString: PBMVastRequiredModeAll]) {
        //Can we play all of them?
        ret = self.feasibleCompanions.count == self.companions.count;
    } else if ([self.requiredMode isEqualToString: PBMVastRequiredModeAny]) {
        //Can we play any of them?
        
        //TODO: This logic always returns true.
        if (self.companions.count == 0) {
            ret = YES;
        } else {
            ret = self.feasibleCompanions.count > 0;
        }
    }
    return ret;
}

-(void)copyTracking:(PBMVastCreativeCompanionAds *)fromCompanionAds {
    if (!fromCompanionAds) {
        return;
    }
    
    for (PBMVastCreativeCompanionAdsCompanion *fromCompanion in fromCompanionAds.companions) {
        for (PBMVastCreativeCompanionAdsCompanion *toCompanion in self.companions) {
            [toCompanion.clickTrackingURIs addObjectsFromArray:fromCompanion.clickTrackingURIs];
            [toCompanion.trackingEvents addTrackingEvents:fromCompanion.trackingEvents];
        }
    }
}

@end
