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

#import <UIKit/UIKit.h>

#import "PBMModalManagerDelegate.h"
#import "PBMModalViewControllerDelegate.h"
#import "PBMVoidBlock.h"

@class PBMModalState;
@class PBMDeferredModalState;
@class PBMAbstractCreative;
@class PBMModalViewController;
@class PBMModalState;

NS_ASSUME_NONNULL_BEGIN

@interface PBMModalManager : NSObject <PBMModalViewControllerDelegate>

@property (nonatomic, strong, nullable) PBMModalViewController *modalViewController;

//The VC class to use to display modals. Defaults is nil.
@property (nullable) Class modalViewControllerClass;

- (instancetype)init;
- (instancetype)initWithDelegate:(nullable id<PBMModalManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (nullable PBMVoidBlock)pushModal:(PBMModalState *)state
            fromRootViewController:(UIViewController *)fromRootViewController
                          animated:(BOOL)animated
                     shouldReplace:(BOOL)shouldReplace
                 completionHandler:(nullable PBMVoidBlock)completionHandler;

- (void)pushDeferredModal:(PBMDeferredModalState *)deferredModalState;

- (void)dismissAllInterstitialsIfAny;
- (void)creativeDisplayCompleted:(PBMAbstractCreative *)creative;
- (void)forceOrientation:(UIInterfaceOrientation)forcedOrientation NS_SWIFT_NAME(forceOrientation(_:));

- (void)hideModalAnimated:(BOOL)animated completionHandler:(nullable PBMVoidBlock)completionHandler;
- (void)backModalAnimated:(BOOL)animated fromRootViewController:(nullable UIViewController *)fromRootViewController completionHandler:(nullable PBMVoidBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
