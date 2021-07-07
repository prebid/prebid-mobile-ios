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

#import "PBMViewControllerProvider.h"
#import "PBMCreativeClickHandlerBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMediaHooks : NSObject

/// Implicit implementor of [PBMAdViewManagerDelegate viewControllerForModalPresentation]
/// Required by PBMAdViewManager to successfully embed cretive views into containers.
/// Might be useful in case of MRAID in End Card.
@property (nonatomic, copy, readonly) PBMViewControllerProvider viewControllerProvider;

/// Click handler's behavior depends not solely on specific asset's link, but also on the parent's (native ad's) link object.
/// Thus the appropriate behavior should be calculated and injected from the higher levels.
@property (nonatomic, copy, nullable) PBMCreativeClickHandlerBlock clickHandlerOverride;

- (instancetype)initWithViewControllerProvider:(PBMViewControllerProvider)viewControllerProvider
                          clickHandlerOverride:(PBMCreativeClickHandlerBlock)clickHandlerOverride NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
