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

#import "PBMMRAIDController.h"

@class PBMWebView;

NS_ASSUME_NONNULL_BEGIN

@interface PBMMRAIDController ()

@property (nonatomic, strong, nullable) PBMWebView *prebidWebView;
@property (nonatomic, strong, nullable) UIViewController* viewControllerForPresentingModals;

+ (CGRect)CGRectForResizeProperties:(PBMMRAIDResizeProperties *)properties fromView:(UIView *)fromView;

- (instancetype)initWithCreative:(PBMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(PBMWebView*)webView
            creativeViewDelegate:(id<PBMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(PBMCreativeFactoryDownloadDataCompletionClosure)downloadBlock
        deviceAccessManagerClass:(Class)deviceAccessManagerClass
                sdkConfiguration:(Prebid *)sdkConfiguration;

- (PBMMRAIDCommand*)commandFromURL:(nullable NSURL*)url;
@end

NS_ASSUME_NONNULL_END
