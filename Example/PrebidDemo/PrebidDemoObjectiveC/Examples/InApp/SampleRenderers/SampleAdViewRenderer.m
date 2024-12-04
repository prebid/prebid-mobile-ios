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

#import "SampleAdViewRenderer.h"

@implementation SampleAdViewRenderer

@synthesize name;
@synthesize version;
@synthesize data;

- (instancetype)init {
    self = [super init];
    if (self) {
        name = @"SampleAdViewRenderer";
        version = @"1.0.0";
    }
    return self;
}

- (BOOL)isSupportRenderingFor:(AdFormat *)format {
    return [@[AdFormat.banner, AdFormat.video] containsObject:format];
}

- (UIView<PrebidMobileDisplayViewProtocol> * _Nullable)createAdViewWith:(CGRect)frame
                                                                    bid:(Bid * _Nonnull)bid
                                                        adConfiguration:(AdUnitConfig * _Nonnull)adConfiguration
                                                        loadingDelegate:(id<DisplayViewLoadingDelegate> _Nonnull)loadingDelegate
                                                    interactionDelegate:(id<DisplayViewInteractionDelegate> _Nonnull)interactionDelegate {
    SampleAdView *adView = [[SampleAdView alloc] initWithFrame:frame];
    
    adView.interactionDelegate = interactionDelegate;
    adView.loadingDelegate = loadingDelegate;
    adView.bid = bid;
    
    return adView;
}

@end
