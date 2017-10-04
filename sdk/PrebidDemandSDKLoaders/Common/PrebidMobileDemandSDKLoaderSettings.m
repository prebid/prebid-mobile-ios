/*   Copyright 2017 APPNEXUS INC
 
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

#import "PBConstants.h"
#import "PrebidMobileDemandSDKLoaderSettings.h"

@interface PrebidMobileDemandSDKLoaderSettings ()

@property (nonatomic, strong) NSMutableSet *demandSet;

@end

@implementation PrebidMobileDemandSDKLoaderSettings

static PrebidMobileDemandSDKLoaderSettings *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
	dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

+ (void)resetSharedInstance {
	onceToken = 0;
	sharedInstance = nil;
}

- (void)enableDemandSources:(nonnull NSArray<NSNumber *> *)demandSources {
	for (NSNumber *demandSource in demandSources) {
        [self makeAssertationsForDemandSource:demandSource];
	}
}

- (void)makeAssertationsForDemandSource:(NSNumber *)demandSource {
	switch ([demandSource intValue]) {
        case PBDemandSourceFacebook:
            [self assertAudienceNetworkSDKExists];
            [self addDemandToDemandSet:@(PBDemandSourceFacebook)];
            break;
        }
}

// In order for fb demand integration to work
// these classes and methods must exist in the FB SDK
- (void)assertAudienceNetworkSDKExists {
    // Banner assertations
	Class fbAdViewClass = NSClassFromString(kFBAdViewClassName);
	assert(fbAdViewClass != nil);
	id fbAdViewObj = [fbAdViewClass alloc];
	SEL initMethodSel = NSSelectorFromString(kFBAdViewInitMethodSelName);
	SEL setDelegateSel = NSSelectorFromString(kFBSetDelegateSelName);
	SEL disableAutoRefreshSel = NSSelectorFromString(kFBAdViewDisableAutoRefreshSelName);
	SEL loadAdWithBidPayloadSel = NSSelectorFromString(kFBLoadAdWithBidPayloadSelName);
	assert([fbAdViewObj respondsToSelector:initMethodSel]);
	assert([fbAdViewObj respondsToSelector:setDelegateSel]);
    assert([fbAdViewObj respondsToSelector:disableAutoRefreshSel]);
	assert([fbAdViewObj respondsToSelector:loadAdWithBidPayloadSel]);

	// Interstitial assertations
	Class fbInterstitialAdClass = NSClassFromString(kFBInterstitialAdClassName);
	assert(fbInterstitialAdClass != nil);
	id fbInterstitialAdObj = [fbInterstitialAdClass alloc];
	SEL intInitMethodSel = NSSelectorFromString(kFBInterstitialInitMethodSelName);
	assert([fbInterstitialAdObj respondsToSelector:intInitMethodSel]);
	assert([fbInterstitialAdObj respondsToSelector:setDelegateSel]);
	assert([fbInterstitialAdObj respondsToSelector:loadAdWithBidPayloadSel]);
}

- (void)addDemandToDemandSet:(NSNumber *)demand {
	if (self.demandSet) {
        [self.demandSet addObject:demand];
	} else {
        self.demandSet = [[NSMutableSet alloc] init];
        [self.demandSet addObject:demand];
	}
}

- (BOOL)isDemandEnabled:(NSString *)demand {
	if (self.demandSet) {
        if ([demand isEqualToString:@"audienceNetwork"]) {
            return [self.demandSet containsObject:@(PBDemandSourceFacebook)];
        }
	}
	return NO;
}

@end
