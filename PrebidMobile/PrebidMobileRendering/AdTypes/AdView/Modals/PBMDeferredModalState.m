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

#import "PBMDeferredModalState.h"
#import "PBMModalManager.h"
#import "PBMMacros.h"

@interface PBMDeferredModalState()

@property (nonatomic, weak, nullable, readonly) UIViewController *rootViewController;
@property (nonatomic, assign, readonly) BOOL animated;
@property (nonatomic, assign, readonly) BOOL shouldReplace;
@property (nonatomic, strong, readonly) PBMDeferredModalStatePreparationBlock preparationBlock;
@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onWillBePushedBlock;
@property (nonatomic, strong, nullable, readonly) PBMDeferredModalStatePushStartHandler onPushStartedBlock;
@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onPushCompletedBlock;
@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onPushCancelledBlock;

@property (nonatomic, weak, nullable) PBMModalManager *modalManager;
@property (nonatomic, strong, nullable) PBMVoidBlock discardBlock;

@property (nonatomic, assign) BOOL hasStarted;
@property (nonatomic, assign) BOOL hasResolved;

@end

// MARK: -

@implementation PBMDeferredModalState

- (instancetype)initWithModalState:(PBMModalState *)modalState
            fromRootViewController:(UIViewController *)rootViewController
                          animated:(BOOL)animated
                     shouldReplace:(BOOL)shouldReplace
                  preparationBlock:(PBMDeferredModalStatePreparationBlock)preparationBlock
                    onWillBePushed:(nullable PBMVoidBlock)onWillBePushedBlock
                     onPushStarted:(nullable PBMDeferredModalStatePushStartHandler)onPushStartedBlock
                   onPushCompleted:(nullable PBMVoidBlock)onPushCompletedBlock
                   onPushCancelled:(nullable PBMVoidBlock)onPushCancelledBlock
{
    if(!(self = [super init])) {
        return nil;
    }
    _modalState = modalState;
    _rootViewController = rootViewController;
    _animated = animated;
    _shouldReplace = shouldReplace;
    _preparationBlock = preparationBlock;
    _onWillBePushedBlock = onWillBePushedBlock;
    _onPushStartedBlock = onPushStartedBlock;
    _onPushCompletedBlock = onPushCompletedBlock;
    _onPushCancelledBlock = onPushCancelledBlock;
    
    _hasStarted = NO;
    _hasResolved = NO;
    
    return self;
}

- (void)prepareAndPushWithModalManager:(PBMModalManager *)modalManager discardBlock:(PBMVoidBlock)discardBlock {
    if (self.hasStarted) {
        return;
    }
    self.hasStarted = YES;
    self.modalManager = modalManager;
    self.discardBlock = discardBlock;
    @weakify(self);
    self.preparationBlock(^(BOOL success) {
        @strongify(self);
        if (!self) { return; }
        
        if (!self.hasResolved) {
            self.hasResolved = YES;
            [self onPreparationFinished:success];
        }
    });
}

- (void)onPreparationFinished:(BOOL)success {
    if (success && self.rootViewController != nil && self.modalManager != nil) {
        if (self.onWillBePushedBlock != nil) {
            self.onWillBePushedBlock();
        }
        
        PBMVoidBlock removeStateBlock = [self.modalManager pushModal:self.modalState
                                              fromRootViewController:self.rootViewController
                                                            animated:self.animated
                                                       shouldReplace:self.shouldReplace
                                                   completionHandler:self.onPushCompletedBlock];
        if (self.onPushStartedBlock && removeStateBlock) {
            self.onPushStartedBlock(removeStateBlock);
        }
    } else {
        if (self.discardBlock != nil) {
            self.discardBlock();
        }
        
        if (self.onPushCancelledBlock != nil) {
            self.onPushCancelledBlock();
        }
    }
    self.discardBlock = nil; // should no longer occur -- no more reason to keep it alive.
}

@end
