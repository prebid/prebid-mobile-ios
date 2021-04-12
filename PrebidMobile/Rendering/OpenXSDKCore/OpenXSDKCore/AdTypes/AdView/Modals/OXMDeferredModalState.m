//
//  OXMDeferredModalState.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMDeferredModalState.h"
#import "OXMModalManager.h"
#import "OXMMacros.h"

@interface OXMDeferredModalState()

@property (nonatomic, weak, nullable, readonly) UIViewController *rootViewController;
@property (nonatomic, assign, readonly) BOOL animated;
@property (nonatomic, assign, readonly) BOOL shouldReplace;
@property (nonatomic, strong, readonly) OXMDeferredModalStatePreparationBlock preparationBlock;
@property (nonatomic, strong, nullable, readonly) OXMVoidBlock onWillBePushedBlock;
@property (nonatomic, strong, nullable, readonly) OXMDeferredModalStatePushStartHandler onPushStartedBlock;
@property (nonatomic, strong, nullable, readonly) OXMVoidBlock onPushCompletedBlock;
@property (nonatomic, strong, nullable, readonly) OXMVoidBlock onPushCancelledBlock;

@property (nonatomic, weak, nullable) OXMModalManager *modalManager;
@property (nonatomic, strong, nullable) OXMVoidBlock discardBlock;

@property (nonatomic, assign) BOOL hasStarted;
@property (nonatomic, assign) BOOL hasResolved;

@end

// MARK: -

@implementation OXMDeferredModalState

- (instancetype)initWithModalState:(OXMModalState *)modalState
            fromRootViewController:(UIViewController *)rootViewController
                          animated:(BOOL)animated
                     shouldReplace:(BOOL)shouldReplace
                  preparationBlock:(OXMDeferredModalStatePreparationBlock)preparationBlock
                    onWillBePushed:(nullable OXMVoidBlock)onWillBePushedBlock
                     onPushStarted:(nullable OXMDeferredModalStatePushStartHandler)onPushStartedBlock
                   onPushCompleted:(nullable OXMVoidBlock)onPushCompletedBlock
                   onPushCancelled:(nullable OXMVoidBlock)onPushCancelledBlock
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

- (void)prepareAndPushWithModalManager:(OXMModalManager *)modalManager discardBlock:(OXMVoidBlock)discardBlock {
    if (self.hasStarted) {
        return;
    }
    self.hasStarted = YES;
    self.modalManager = modalManager;
    self.discardBlock = discardBlock;
    @weakify(self);
    self.preparationBlock(^(BOOL success) {
        @strongify(self);
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
        
        OXMVoidBlock removeStateBlock = [self.modalManager pushModal:self.modalState
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
