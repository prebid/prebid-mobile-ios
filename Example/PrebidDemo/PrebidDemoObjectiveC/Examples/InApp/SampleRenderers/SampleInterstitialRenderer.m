/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

#import "SampleInterstitialRenderer.h"
#import "SampleInterstitialController.h"

@implementation SampleInterstitialRenderer

@synthesize name;
@synthesize version;
@synthesize data;

- (instancetype)init {
    self = [super init];
    if (self) {
        name = @"SampleInterstitialRenderer";
        version = @"1.0.0";
    }
    return self;
}

- (BOOL)isSupportRenderingFor:(AdFormat *)format {
    return YES;
}

- (id<PrebidMobileInterstitialControllerProtocol>)createInterstitialControllerWithBid:(Bid *)bid
                                                                      adConfiguration:(AdUnitConfig *)adConfiguration
                                                                      loadingDelegate:(id<InterstitialControllerLoadingDelegate>)loadingDelegate
                                                                  interactionDelegate:(id<InterstitialControllerInteractionDelegate>)interactionDelegate {
    SampleInterstitialController *interstitialController = [[SampleInterstitialController alloc] init];
    
    interstitialController.loadingDelegate = loadingDelegate;
    interstitialController.interactionDelegate = interactionDelegate;
    interstitialController.bid = bid;
    
    return interstitialController;
}

@end
