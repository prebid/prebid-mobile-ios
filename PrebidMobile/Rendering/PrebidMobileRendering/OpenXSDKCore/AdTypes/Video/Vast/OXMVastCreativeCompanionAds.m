//
//  OXMVastCreativeCompanionAds.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastCreativeCompanionAds.h"
#import "OXMVastGlobals.h"

#pragma mark - Private Extension

@interface OXMVastCreativeCompanionAds()

//TODO: Change to an internal var with a get
@property (nonatomic, strong, nullable) NSMutableArray<OXMVastCreativeCompanionAdsCompanion *> *myFeasibleCompanions;

@end

#pragma mark - Implementation

@implementation OXMVastCreativeCompanionAds

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

-(NSArray<OXMVastCreativeCompanionAdsCompanion *> *)feasibleCompanions {
    if (!self.myFeasibleCompanions) {
        self.myFeasibleCompanions = [NSMutableArray array];
        for (OXMVastCreativeCompanionAdsCompanion *companion in self.companions) {
            if (! (companion.resourceType == OXMVastResourceTypeStaticResource &&
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
    if ([self.requiredMode isEqualToString: OXMVastRequiredModeAll]) {
        //Can we play all of them?
        ret = self.feasibleCompanions.count == self.companions.count;
    } else if ([self.requiredMode isEqualToString: OXMVastRequiredModeAny]) {
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

-(void)copyTracking:(OXMVastCreativeCompanionAds *)fromCompanionAds {
    if (!fromCompanionAds) {
        return;
    }
    
    for (OXMVastCreativeCompanionAdsCompanion *fromCompanion in fromCompanionAds.companions) {
        for (OXMVastCreativeCompanionAdsCompanion *toCompanion in self.companions) {
            [toCompanion.clickTrackingURIs addObjectsFromArray:fromCompanion.clickTrackingURIs];
            [toCompanion.trackingEvents addTrackingEvents:fromCompanion.trackingEvents];
        }
    }
}

@end
