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
#import "PBMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;
@class PBMModalState;
@class PBMModalManager;

typedef void (^PBMDeferredModalStateResolutionHandler)(BOOL success);
typedef void (^PBMDeferredModalStatePreparationBlock)(PBMDeferredModalStateResolutionHandler completionBlock);

typedef void (^PBMDeferredModalStatePushStartHandler)(PBMVoidBlock stateRemovalBlock);

@interface PBMDeferredModalState : NSObject

@property (nonatomic, strong, readonly) PBMModalState * modalState;

- (instancetype)initWithModalState:(PBMModalState *)modalState
            fromRootViewController:(UIViewController *)rootViewController
                          animated:(BOOL)animated
                     shouldReplace:(BOOL)shouldReplace
                  preparationBlock:(PBMDeferredModalStatePreparationBlock)preparationBlock
                    onWillBePushed:(nullable PBMVoidBlock)onWillBePushedBlock
                     onPushStarted:(nullable PBMDeferredModalStatePushStartHandler)onPushStartedBlock
                   onPushCompleted:(nullable PBMVoidBlock)onPushCompletedBlock
                   onPushCancelled:(nullable PBMVoidBlock)onPushCancelledBlock;

- (void)prepareAndPushWithModalManager:(PBMModalManager *)modalManager discardBlock:(PBMVoidBlock)discardBlock;

@end

NS_ASSUME_NONNULL_END
