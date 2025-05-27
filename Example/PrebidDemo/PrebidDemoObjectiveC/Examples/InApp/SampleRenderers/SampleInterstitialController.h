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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@import PrebidMobile;

NS_ASSUME_NONNULL_BEGIN

/// An example showcasing the implementation of the `PrebidMobileInterstitialControllerProtocol`.
/// A sample controller that is used for rendering ads.
@interface SampleInterstitialController : NSObject <PrebidMobileInterstitialControllerProtocol>

@property (nonatomic, weak) id<InterstitialControllerLoadingDelegate> loadingDelegate;
@property (nonatomic, weak) id<InterstitialControllerInteractionDelegate> interactionDelegate;
@property (nonatomic, strong) Bid *bid;

@end

NS_ASSUME_NONNULL_END
