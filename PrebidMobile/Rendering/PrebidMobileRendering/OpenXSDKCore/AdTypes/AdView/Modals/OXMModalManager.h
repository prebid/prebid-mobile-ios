//
//  OXMModalManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "OXMModalManagerDelegate.h"
#import "OXMModalViewControllerDelegate.h"
#import "OXMVoidBlock.h"

@class OXMModalState;
@class OXMDeferredModalState;
@class OXMAbstractCreative;
@class OXMModalViewController;
@class OXMModalState;

NS_ASSUME_NONNULL_BEGIN

@interface OXMModalManager : NSObject <OXMModalViewControllerDelegate>

@property (nonatomic, strong, nullable) OXMModalViewController *modalViewController;

//The VC class to use to display modals. Defaults is nil.
@property (nullable) Class modalViewControllerClass;

- (instancetype)init;
- (instancetype)initWithDelegate:(nullable id<OXMModalManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (nullable OXMVoidBlock)pushModal:(OXMModalState *)state
            fromRootViewController:(UIViewController *)fromRootViewController
                          animated:(BOOL)animated
                     shouldReplace:(BOOL)shouldReplace
                 completionHandler:(nullable OXMVoidBlock)completionHandler;

- (void)pushDeferredModal:(OXMDeferredModalState *)deferredModalState;

- (void)dismissAllInterstitialsIfAny;
- (void)creativeDisplayCompleted:(OXMAbstractCreative *)creative;
- (void)forceOrientation:(UIInterfaceOrientation)forcedOrientation NS_SWIFT_NAME(forceOrientation(_:));

- (void)hideModalAnimated:(BOOL)animated completionHandler:(nullable OXMVoidBlock)completionHandler;
- (void)backModalAnimated:(BOOL)animated fromRootViewController:(nullable UIViewController *)fromRootViewController completionHandler:(nullable OXMVoidBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
