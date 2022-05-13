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

#import <Foundation/Foundation.h>

#import "PBMConstants.h"
#import "PBMCreativeFactory.h"

#import "PBMCreativeViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class PBMAbstractCreative;
@class PBMModalManager;
@class PBMWebView;
@class PBMMRAIDCommand;
@class PBMOpenMeasurementSession;

@interface PBMMRAIDController : NSObject

@property (nonatomic, assign, nonnull) PBMMRAIDState mraidState;

+(BOOL)isMRAIDLink:(NSString *)urlString;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreative:(PBMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(PBMWebView*)webView
            creativeViewDelegate:(id<PBMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(PBMCreativeFactoryDownloadDataCompletionClosure)downloadBlock;

- (void)webView:(PBMWebView *)webView handleMRAIDURL:(NSURL *)url;
- (void)updateForClose:(BOOL)isInterstitial;

@end

NS_ASSUME_NONNULL_END
