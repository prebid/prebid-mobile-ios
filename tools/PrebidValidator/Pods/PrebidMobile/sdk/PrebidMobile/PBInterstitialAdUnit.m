/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PBInterstitialAdUnit.h"

static NSInteger const kNumSizes = 11;
static NSInteger const kSizeXY = 2;

@implementation PBInterstitialAdUnit

- (nonnull instancetype)initWithAdUnitIdentifier:(nonnull NSString *)identifier andConfigId:(nonnull NSString *)configId {
    PBInterstitialAdUnit *interstitialAdUnit = [super initWithIdentifier:identifier andAdType:PBAdUnitTypeInterstitial andConfigId:configId];
    [self addSizesToInterstitialAdUnit:interstitialAdUnit];
    return interstitialAdUnit;
}

- (void)addSizesToInterstitialAdUnit:(PBInterstitialAdUnit *)adUnit {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    int size[kNumSizes][kSizeXY] = {{300, 250}, {300, 600}, {320, 250}, {254, 133}, {580, 400}, {320, 320}, {320, 160}, {320, 480}, {336, 280}, {320, 400}, {1, 1}};

    for (int i = 0; i < kNumSizes; i++) {
        CGSize sizeObj = CGSizeMake(size[i][0], size[i][1]);
        if (sizeObj.width <= screenSize.size.width && sizeObj.height <= screenSize.size.height) {
            [adUnit addSize:sizeObj];
        }
    }
}

@end
