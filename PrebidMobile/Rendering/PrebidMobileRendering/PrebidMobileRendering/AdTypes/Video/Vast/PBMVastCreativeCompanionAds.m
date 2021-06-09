/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
