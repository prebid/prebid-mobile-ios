//
//  PBMModalManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

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
