//
//  PBMDeferredModalState.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

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
