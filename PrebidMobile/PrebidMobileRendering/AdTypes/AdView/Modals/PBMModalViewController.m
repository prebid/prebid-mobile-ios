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

#import "PBMCreativeModel.h"
#import "PBMMacros.h"
#import "PBMModalState.h"
#import "PBMModalViewController.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMFunctions+Private.h"
#import "UIView+PBMExtensions.h"
#import "PBMModalManager.h"
#import "PBMWebView.h"
#import "PBMCloseActionManager.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Private Extension

@interface PBMModalViewController ()

@property (nonatomic, strong) PBMVoidBlock showCloseButtonBlock;
@property (nonatomic, strong) NSDate *startCloseDelay;

@property (nonatomic, assign) BOOL preferAppStatusBarHidden;

@property (nonatomic, strong) PBMAdViewButtonDecorator *closeButtonDecorator;
@property (nonatomic, assign) PBMInterstitialLayout interstitialLayout;

@end

#pragma mark - Implementation

@implementation PBMModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCloseButton];
    [self setupContentView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.preferAppStatusBarHidden = ![UIApplication sharedApplication].isStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.preferAppStatusBarHidden = !self.prefersStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask orientationMask = (self.interstitialLayout == PBMInterstitialLayoutLandscape) ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
    return self.rotationEnabled ? UIInterfaceOrientationMaskAll : orientationMask;
}

- (BOOL)shouldAutorotate {
    return self.rotationEnabled;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rotationEnabled = YES;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Hiding status bar (iOS 7 and above)

- (BOOL)prefersStatusBarHidden {
    return self.preferAppStatusBarHidden;
}

#pragma mark - Internal Properties

- (UIView *)displayView {
    return self.modalState.view;
}

- (PBMInterstitialDisplayProperties *)displayProperties {
    return self.modalState.displayProperties;
}

#pragma mark - Public Methods

- (void)setupState:(nonnull PBMModalState *)modalState {
    // STEP 1: Remove the old view
    if (self.displayView && self.displayView.superview && self.displayView.superview == self.contentView) {
        [self.displayView removeFromSuperview];
    }
    
    if (self.showCloseButtonBlock) {
        [self onCloseDelayInterrupted];
    }
    
    // STEP 2: Replace the modal state
    self.interstitialLayout = modalState.displayProperties.interstitialLayout;
    self.modalState = modalState;
    if (modalState.displayProperties.interstitialLayout == PBMInterstitialLayoutUndefined) {
        self.rotationEnabled = modalState.rotationEnabled;
    } else {
        self.rotationEnabled = modalState.displayProperties.rotationEnabled;
    }

    [self configureSubView];
    [self configureCloseButton];
}

- (void)closeButtonTapped {
    [self.modalViewControllerDelegate modalViewControllerCloseButtonTapped:self];
}

- (void)addFriendlyObstructionsToMeasurementSession:(PBMOpenMeasurementSession *)session {
    [session addFriendlyObstruction:self.view purpose:PBMOpenMeasurementFriendlyObstructionModalViewControllerView];
    [session addFriendlyObstruction:self.closeButtonDecorator.button purpose:PBMOpenMeasurementFriendlyObstructionModalViewControllerClose];
}

#pragma mark - Internal Methods

- (void)setupCloseButton {
    self.closeButtonDecorator = [PBMAdViewButtonDecorator new];
    self.closeButtonDecorator.button.hidden = YES;
}

- (void)setupContentView {
    
    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.contentView];
    
    if (@available(iOS 11.0, *)) {
        // Set up autolayout constraints on iOS 11+. This contentView should always stay within the safe area.
        [self addSafeAreaConstraintsToView:self.contentView];
        return;
    }
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    
    [self.view addConstraints: [NSArray arrayWithObjects:width, height, centerX, centerY, nil]];
}

// Adds the current view to the contentView if
// - the current view is not nil,
// - the contentView is not nil,
// - the current isn't already added to the modal somewhere
- (void)configureSubView {
    if (!self.displayView) {
        PBMLogError(@"Attempted to display a nil view");
        return;
    }
    
    if (!self.contentView) {
        PBMLogError(@"ContentView not yet set up by InterfaceBuilder. Nothing to add content to");
        return;
    }
    
    if ([self.displayView isDescendantOfView:self.view]) {
        PBMLogError(@"currentDisplayView is already a child of self.view");
        return;
    }
    
    [self.contentView addSubview:self.displayView];
    
    [self configureDisplayView];
}

- (void)configureDisplayView {    
    PBMInterstitialDisplayProperties *props = self.displayProperties;
    if (!props || CGRectIsInfinite(props.contentFrame)) {
        [self.displayView PBMAddFillSuperviewConstraints];
    }
    else {
        self.contentView.backgroundColor = props.contentViewColor;
        self.displayView.backgroundColor = [UIColor clearColor];
        [self.displayView PBMAddConstraintsFromCGRect: props.contentFrame];
    }
}

- (void)addSafeAreaConstraintsToView:(UIView *)view {
    
    if (@available(iOS 11.0, *)) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
                                                  [view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
                                                  [view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
                                                  [view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
                                                  [view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
                                                  ]];
    }
}

#pragma mark - Helper Methods (Close button)

- (void)configureCloseButton {

    if ([self.modalState.view isKindOfClass:[PBMWebView class]]) {
        PBMWebView *webView = (PBMWebView *)self.modalState.view;
        self.closeButtonDecorator.isMRAID = webView.isMRAID;        
    }    
    self.closeButtonDecorator.buttonArea = self.modalState.adConfiguration.videoControlsConfig.closeButtonArea;
    self.closeButtonDecorator.buttonPosition = self.modalState.adConfiguration.videoControlsConfig.closeButtonPosition;
    [self.closeButtonDecorator setImage:[self.displayProperties getCloseButtonImage]];
    [self.closeButtonDecorator addButtonTo:self.view displayView:self.displayView];
    [self setupCloseButtonVisibility];
    
    @weakify(self);
    self.closeButtonDecorator.buttonTouchUpInsideBlock = ^{
        @strongify(self);
        if (!self) { return; }
        
        [self closeButtonTapped];
    };
}

- (void)setupCloseButtonVisibility {
    // Set the close button view visibilty based on th view context (i.e. normal, clickthrough browser, rewarded video)
    [self.closeButtonDecorator bringButtonToFront];
    if (self.modalState.adConfiguration.isRewarded) {
        return; // Must be hidden
    }
    else if (self.displayProperties && self.displayProperties.closeDelay > 0) {
        if (self.displayProperties.closeDelayLeft <= 0) {
            return;
        }
    
        // Force hiding. If the close delay presents, need to hide the button.
        self.closeButtonDecorator.button.hidden = YES;
        [self setupCloseButtonDelay];
    }
    else {
        self.closeButtonDecorator.button.hidden = NO;
    }
}

- (void)creativeDisplayCompleted:(PBMAbstractCreative *)creative {
    if (self.modalState.adConfiguration.isRewarded) {
        PBMRewardedConfig * rewardedConfig = creative.creativeModel.adConfiguration.rewardedConfig;
        
        NSString * ortbAction = rewardedConfig.closeAction ?: @"";
        
        PBMCloseAction action = [PBMCloseActionManager getActionWithDescription:ortbAction];
        
        switch(action) {
            case PBMCloseActionCloseButton:
                self.closeButtonDecorator.button.hidden = NO;
                break;
            case PBMCloseActionAutoClose:
                [self.modalViewControllerDelegate modalViewControllerCloseButtonTapped:self];
                break;
            case PBMCloseActionUnknown:
                // By default SDK should show close button
                self.closeButtonDecorator.button.hidden = NO;
                PBMLogWarn(@"SDK met unknown close action.")
        }
    }
}

- (void)setupCloseButtonDelay {
    
    @weakify(self);
    self.showCloseButtonBlock = ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        self.closeButtonDecorator.button.hidden = NO;
        [self onCloseDelayInterrupted];
    };
    
    NSDate *startCloseDelay = [NSDate date];
    self.startCloseDelay = startCloseDelay;
    
    dispatch_time_t dispatchTime = [PBMFunctions dispatchTimeAfterTimeInterval:self.displayProperties.closeDelayLeft];
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        // The current block could be called twice: once for the initial timer and once for the restored one.
        // So need to check the creation timestamp of the current block before execution.
        if (self.showCloseButtonBlock && [self.startCloseDelay isEqualToDate:startCloseDelay]) {
            self.showCloseButtonBlock();
        }
    });
}

- (void)onCloseDelayInterrupted {
    NSTimeInterval displayTime = [[NSDate date] timeIntervalSinceDate:self.startCloseDelay];
    
    if (displayTime > 0) {
        self.displayProperties.closeDelayLeft = self.displayProperties.closeDelayLeft - displayTime;
    }
    
    self.startCloseDelay = nil;
    self.showCloseButtonBlock = nil;
}

@end
