//
//  OXMModalViewController.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//


#import "OXMAdConfiguration.h"
#import "OXMClickthroughBrowserView.h"
#import "OXMCreativeModel.h"
#import "OXMMacros.h"
#import "OXMModalState.h"
#import "OXMModalViewController.h"
#import "OXMOpenMeasurementSession.h"
#import "OXMFunctions+Private.h"
#import "UIView+OxmExtensions.h"
#import "OXMCloseButtonDecorator.h"
#import "OXMMacros.h"
#import "OXMModalManager.h"
#import "OXMWebView.h"

#pragma mark - Private Extension

@interface OXMModalViewController ()

@property (nonatomic, strong) OXMVoidBlock showCloseButtonBlock;
@property (nonatomic, strong) NSDate *startCloseDelay;

@property (nonatomic, assign) BOOL preferAppStatusBarHidden;

@property (nonatomic, strong) OXMCloseButtonDecorator *closeButtonDecorator;
@property (nonatomic, assign) OXMInterstitialLayout interstitialLayout;

@end

#pragma mark - Implementation

@implementation OXMModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCloseButton];
    [self setupLegalButton];
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
    UIInterfaceOrientationMask orientationMask = (self.interstitialLayout == OXMInterstitialLayoutLandscape) ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
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

- (OXMInterstitialDisplayProperties *)displayProperties {
    return self.modalState.displayProperties;
}

#pragma mark - Public Methods

- (void)setupState:(nonnull OXMModalState *)modalState {
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
    if (modalState.displayProperties.interstitialLayout == OXMInterstitialLayoutUndefined) {
        self.rotationEnabled = modalState.rotationEnabled;
    } else {
        self.rotationEnabled = modalState.displayProperties.rotationEnabled;
    }

    [self configureSubView];
    [self configureCloseButton];
    [self configureLegalButton: modalState];
    [self configureClickThroughDelegate];
}

- (void)closeButtonTapped {
    [self.modalViewControllerDelegate modalViewControllerCloseButtonTapped:self];
}

- (void)addFriendlyObstructionsToMeasurementSession:(OXMOpenMeasurementSession *)session {
    [session addFriendlyObstruction:self.view purpose:OXMOpenMeasurementFriendlyObstructionModalViewControllerView];
    [session addFriendlyObstruction:self.closeButtonDecorator.button purpose:OXMOpenMeasurementFriendlyObstructionModalViewControllerClose];
    [session addFriendlyObstruction:self.legalButtonDecorator.button purpose:OXMOpenMeasurementFriendlyObstructionLegalButtonDecorator];
}

#pragma mark - Internal Methods

- (void)setupCloseButton {
    self.closeButtonDecorator = [OXMCloseButtonDecorator new];
    self.closeButtonDecorator.button.hidden = YES;
}

- (void)setupLegalButton {
    self.legalButtonDecorator = [[OXMLegalButtonDecorator alloc] initWithPosition:OXMPositionBottomRight];
    self.legalButtonDecorator.button.hidden = YES;
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
        OXMLogError(@"Attempted to display a nil view");
        return;
    }
    
    if (!self.contentView) {
        OXMLogError(@"ContentView not yet set up by InterfaceBuilder. Nothing to add content to");
        return;
    }
    
    if ([self.displayView isDescendantOfView:self.view]) {
        OXMLogError(@"currentDisplayView is already a child of self.view");
        return;
    }
    
    [self.contentView addSubview:self.displayView];
    
    [self configureDisplayView];
}

- (void)configureDisplayView {    
    OXMInterstitialDisplayProperties *props = self.displayProperties;
    if (!props || CGRectIsInfinite(props.contentFrame)) {
        [self.displayView OXMAddFillSuperviewConstraints];
    }
    else {
        self.contentView.backgroundColor = props.contentViewColor;
        self.displayView.backgroundColor = [UIColor clearColor];
        [self.displayView OXMAddConstraintsFromCGRect: props.contentFrame];
    }
}

- (void)configureClickThroughDelegate {
    // If the view is a ClickthroughBrowserView, set its delegate to the interstitialVC so it can respond to UI Events passed from the ClickthroughBrowserView
    if ([self.modalState.view isKindOfClass:[OXMClickthroughBrowserView class]]) {
        OXMClickthroughBrowserView *clickthroughBrowserView = (OXMClickthroughBrowserView *)self.modalState.view;
        clickthroughBrowserView.clickThroughBrowserViewDelegate = self;
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

#pragma mark - OXMClickthroughBrowserViewDelegate

- (void)clickThroughBrowserViewCloseButtonTapped {
    //Treat a tap on the "X" button on the clickthroughBrowserView as being
    //equivalent to tapping the ModalViewController's own close button.
    [self closeButtonTapped];
}

- (void)clickThroughBrowserViewWillLeaveApp {
    [self.modalViewControllerDelegate modalViewControllerDidLeaveApp];
}

#pragma mark - Helper Methods (Close button)

- (void)configureCloseButton {

    if ([self.modalState.view isKindOfClass:[OXMWebView class]]) {
        OXMWebView *webView = (OXMWebView *)self.modalState.view;
        self.closeButtonDecorator.isMRAID = webView.isMRAID;        
    }    
    
    [self.closeButtonDecorator setImage:[self.displayProperties getCloseButtonImage]];
    [self.closeButtonDecorator addButtonToView:self.view displayView:self.displayView];
    [self setupCloseButtonVisibility];
    
    @weakify(self);
    self.closeButtonDecorator.buttonTouchUpInsideBlock = ^{
        @strongify(self);
        [self closeButtonTapped];
    };
}

- (void)setupCloseButtonVisibility {
    // Set the close button view visibilty based on th view context (i.e. normal, clickthrough browser, rewarded video)
    [self.closeButtonDecorator bringButtonToFront];
    if ([self.displayView isKindOfClass:[OXMClickthroughBrowserView class]]) {
        [self.closeButtonDecorator sendSubviewToBack];
        return; // Must be hidden
    }
    else if (self.modalState.adConfiguration.isOptIn && ![self.displayView isKindOfClass:[OXMClickthroughBrowserView class]]) {
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

- (void)configureLegalButton:(nonnull OXMModalState *)modalState {
    [self.legalButtonDecorator addButtonToView:self.view displayView:self.displayView];
    [self.legalButtonDecorator updateButtonConstraints];
    @weakify(self);
    self.legalButtonDecorator.buttonTouchUpInsideBlock = ^{
        @strongify(self);
        if (modalState.onModalPushedBlock != nil) {
            modalState.onModalPushedBlock();
        }
        OXMClickthroughBrowserView *clickthroughBrowserView = [self.legalButtonDecorator clickthroughBrowserView];
        if (clickthroughBrowserView) {
            // FIXME: (mk) Check closure chaining
            OXMModalState *state = [OXMModalState modalStateWithView:clickthroughBrowserView
                                                     adConfiguration:nil
                                                   displayProperties:nil
                                                  onStatePopFinished:self.modalState.nextOnStatePopFinished
                                                   onStateHasLeftApp:self.modalState.nextOnStateHasLeftApp];
            [self.modalManager pushModal:state fromRootViewController:self animated:YES shouldReplace:NO completionHandler:nil];
        }
    };
    
    [self setupLegalButtonVisibility];
}

- (void)setupLegalButtonVisibility {
    [self.legalButtonDecorator bringButtonToFront];
    if ([self.displayView isKindOfClass:[OXMClickthroughBrowserView class]]) {
        [self.legalButtonDecorator sendSubviewToBack];
        return; // Must be hidden
    } else if (self.modalState.adConfiguration.adFormat == OXMAdFormatVideo) {
        [self.legalButtonDecorator sendSubviewToBack];
        return; // Must be hidden for opt-in and insterstitial videos
    } else {
        self.legalButtonDecorator.button.hidden = NO;
    }
}

- (void)creativeDisplayCompleted:(OXMAbstractCreative *)creative {
    if (self.modalState.adConfiguration.isOptIn) {
        self.closeButtonDecorator.button.hidden = NO;
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
    
    dispatch_time_t dispatchTime = [OXMFunctions dispatchTimeAfterTimeInterval:self.displayProperties.closeDelayLeft];
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
