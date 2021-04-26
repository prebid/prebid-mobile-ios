//
//  PBMModalViewController.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBMClickthroughBrowserViewDelegate.h"
#import "PBMModalViewControllerDelegate.h"
#import "PBMLegalButtonDecorator.h"

@class PBMAbstractCreative;
@class PBMModalState;
@class PBMModalManager;
@class PBMOpenMeasurementSession;
@class PBMInterstitialDisplayProperties;

@interface PBMModalViewController : UIViewController <PBMClickthroughBrowserViewDelegate>

@property (nonatomic, weak, nullable) id<PBMModalViewControllerDelegate> modalViewControllerDelegate;
@property (nonatomic, weak, nullable) PBMModalManager *modalManager;

@property (nonatomic, strong, nullable) PBMModalState *modalState;

@property (nonatomic, strong, nullable) UIView *contentView;
@property (nonatomic, readonly, nullable) UIView *displayView;
@property (nonatomic, readonly, nullable) PBMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, strong, nullable) PBMLegalButtonDecorator *legalButtonDecorator;
@property (nonatomic, assign, getter=isRotationEnabled) BOOL rotationEnabled;

- (void)setupState:(nonnull PBMModalState *)modalState;
- (void)creativeDisplayCompleted:(nonnull PBMAbstractCreative *)creative;

- (void)addFriendlyObstructionsToMeasurementSession:(nonnull PBMOpenMeasurementSession *)session;

- (void)configureDisplayView;

@end
