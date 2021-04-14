//
//  OXMModalViewController.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OXMClickthroughBrowserViewDelegate.h"
#import "OXMModalViewControllerDelegate.h"
#import "OXMLegalButtonDecorator.h"

@class OXMAbstractCreative;
@class OXMModalState;
@class OXMModalManager;
@class OXMOpenMeasurementSession;
@class OXMInterstitialDisplayProperties;

@interface OXMModalViewController : UIViewController <OXMClickthroughBrowserViewDelegate>

@property (nonatomic, weak, nullable) id<OXMModalViewControllerDelegate> modalViewControllerDelegate;
@property (nonatomic, weak, nullable) OXMModalManager *modalManager;

@property (nonatomic, strong, nullable) OXMModalState *modalState;

@property (nonatomic, strong, nullable) UIView *contentView;
@property (nonatomic, readonly, nullable) UIView *displayView;
@property (nonatomic, readonly, nullable) OXMInterstitialDisplayProperties *displayProperties;
@property (nonatomic, strong, nullable) OXMLegalButtonDecorator *legalButtonDecorator;
@property (nonatomic, assign, getter=isRotationEnabled) BOOL rotationEnabled;

- (void)setupState:(nonnull OXMModalState *)modalState;
- (void)creativeDisplayCompleted:(nonnull OXMAbstractCreative *)creative;

- (void)addFriendlyObstructionsToMeasurementSession:(nonnull OXMOpenMeasurementSession *)session;

- (void)configureDisplayView;

@end
