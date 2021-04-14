//
//  OXMDeferredModalState.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;
@class OXMModalState;
@class OXMModalManager;

typedef void (^OXMDeferredModalStateResolutionHandler)(BOOL success);
typedef void (^OXMDeferredModalStatePreparationBlock)(OXMDeferredModalStateResolutionHandler completionBlock);

typedef void (^OXMDeferredModalStatePushStartHandler)(OXMVoidBlock stateRemovalBlock);

@interface OXMDeferredModalState : NSObject

@property (nonatomic, strong, readonly) OXMModalState * modalState;

- (instancetype)initWithModalState:(OXMModalState *)modalState
            fromRootViewController:(UIViewController *)rootViewController
                          animated:(BOOL)animated
                     shouldReplace:(BOOL)shouldReplace
                  preparationBlock:(OXMDeferredModalStatePreparationBlock)preparationBlock
                    onWillBePushed:(nullable OXMVoidBlock)onWillBePushedBlock
                     onPushStarted:(nullable OXMDeferredModalStatePushStartHandler)onPushStartedBlock
                   onPushCompleted:(nullable OXMVoidBlock)onPushCompletedBlock
                   onPushCancelled:(nullable OXMVoidBlock)onPushCancelledBlock;

- (void)prepareAndPushWithModalManager:(OXMModalManager *)modalManager discardBlock:(OXMVoidBlock)discardBlock;

@end

NS_ASSUME_NONNULL_END
