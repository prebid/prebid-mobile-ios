//
//  OXMModalManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMModalManager.h"

#import "OXMLog.h"
#import "OXMAdConfiguration.h"
#import "OXMVideoView.h"
#import "OXMDownloadDataHelper.h"
#import "OXMAbstractCreative.h"
#import "OXMFunctions+Private.h"
#import "OXMClickthroughBrowserView.h"
#import "OXMModalPresentationController.h"
#import "OXMModalViewController.h"
#import "OXMNonModalViewController.h"
#import "OXMModalViewControllerDelegate.h"
#import "OXMModalState.h"
#import "OXMDeferredModalState.h"
#import "OXMMacros.h"
#import "OXMModalAnimator.h"

#pragma mark - Constants

static NSString * const OXMInterstitialStoryboardName  = @"Interstitial";

#pragma mark - Private Interface

@interface OXMModalManager()

@property (nonatomic,weak,nullable) id<OXMModalManagerDelegate> delegate;

@property (nonatomic,assign,readwrite) BOOL isModalDismissing;
@property (nonatomic,strong,nullable) OXMDeferredModalState *deferredModalState;

//The last item in this stack represents the view & display properties currently being displayed.
@property (nonatomic, strong, nonnull) NSMutableArray<OXMModalState *> *modalStateStack;

@end

#pragma mark - Implementation

@implementation OXMModalManager

#pragma mark - Initialization

- (instancetype)init {
    return (self = [self initWithDelegate:nil]);
}

- (instancetype)initWithDelegate:(nullable id<OXMModalManagerDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _modalStateStack = [[NSMutableArray alloc] init];
    _delegate = delegate;
    return self;
}

- (void) dealloc {
    OXMLogWhereAmI();
    
    if (_modalViewController) {
        __weak id<OXMModalManagerDelegate> delegate = _delegate;
        [_modalViewController dismissViewControllerAnimated:true completion:^{
            [delegate modalManagerDidDismissModal];
        }];
    }
}

-(NSString *)oxmDescription:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationUnknown : return @"unknown";
        case UIInterfaceOrientationPortrait : return @"portrait";
        case UIInterfaceOrientationPortraitUpsideDown : return @"portraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft : return @"landscapeLeft";
        case UIInterfaceOrientationLandscapeRight : return @"landscapeRight";
    }
}

- (void)forceOrientation:(UIInterfaceOrientation)forcedOrientation {
    //DISCLAIMER: Forcing orientation does not work for iPads
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        OXMLogInfo(@"Forcing orientation to %@", [self oxmDescription:forcedOrientation]);
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: forcedOrientation] forKey:@"orientation"];
    });
}

- (void)creativeDisplayCompleted:(OXMAbstractCreative*)creative {
    [self.modalViewController creativeDisplayCompleted:creative];
}

#pragma mark - External API

- (OXMVoidBlock)pushModal:(OXMModalState *)state
   fromRootViewController:(UIViewController *)fromRootViewController
                 animated:(BOOL)animated
            shouldReplace:(BOOL)shouldReplace
        completionHandler:(OXMVoidBlock)completionHandler {
    
    OXMAssert(state && fromRootViewController);
    if (!(state && fromRootViewController)) {
        OXMLogError(@"Invalid input parameters");
        return nil;
    }
    
    if (self.deferredModalState != nil) {
        if (state != self.deferredModalState.modalState) {
            OXMLogError(@"Attempting to push modal state while another deferred state is being prepared");
            return nil;
        } else {
            // Previously deferred modalState has been resolved and is being pushed
            self.deferredModalState = nil; // no longer deffered
        }
    }
    
    if (shouldReplace && [self.modalStateStack count] > 0) {
        [self.modalStateStack removeLastObject];
    }
    
    //Add the content to the stack
    [self.modalStateStack addObject:state];
    [self display:state fromRootViewController:fromRootViewController animated:animated completionHandler:completionHandler];
    
    return [self removeStateBlock:state];
}

- (void)pushDeferredModal:(nonnull OXMDeferredModalState *)deferredModalState {
    if (self.deferredModalState == nil && !self.isModalDismissing) {
        self.deferredModalState = deferredModalState;
        @weakify(self);
        __weak OXMDeferredModalState *weakDeferredState = deferredModalState;
        [deferredModalState prepareAndPushWithModalManager:self discardBlock:^{
            @strongify(self);
            if (self.deferredModalState != nil && self.deferredModalState == weakDeferredState) {
                self.deferredModalState = nil;
            }
        }];
    }
}

- (nonnull OXMVoidBlock)removeStateBlock:(OXMModalState *)modalState {
    OXMModalState * __weak weakModalState = modalState;
    @weakify(self);
    return ^{
        @strongify(self);
        OXMModalState * const removedState = weakModalState;
        if (removedState) {
            [self removeModal:removedState];
        }
    };
}

- (void)removeModal:(nonnull OXMModalState *)modalState {
    OXMModalState *activeState = [self.modalStateStack lastObject];
    if (activeState == modalState) {
        [self popModal];
    } else {
        [self.modalStateStack removeObject:modalState];
    }
}

- (void)popModal {
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);

        //Is the stack empty?
        OXMModalState *poppedModalState = [self.modalStateStack lastObject];
        if (!poppedModalState) {
            OXMLogError(@"popModal called on empty modalStateStack!");
            return;
        }
                
        [self.modalStateStack removeLastObject];

        //Was that the last modal in the stack?
        OXMModalState *state = [self.modalStateStack lastObject];
        if (state) {
            //There's still at least one left.
            //We need force orientation once again
            if (state.displayProperties.interstitialLayout == OXMInterstitialLayoutLandscape) {
                [self forceOrientation:UIInterfaceOrientationLandscapeLeft];
            } else if (state.displayProperties.interstitialLayout == OXMInterstitialLayoutPortrait) {
                [self forceOrientation:UIInterfaceOrientationPortrait];
            }
            
            [self display:state fromRootViewController:nil animated:false completionHandler:nil];
            if (poppedModalState.onStatePopFinished != nil) {
                poppedModalState.onStatePopFinished(poppedModalState);
            }
        } else {
            //Stack is empty, dismiss the VC.
            [self dismissModalViewControllerWithLastState:poppedModalState];
        }
    });
}

- (void)dismissAllInterstitialsIfAny {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        OXMModalState *poppedModalState = [self.modalStateStack lastObject];
        [self.modalStateStack removeAllObjects];
        [self dismissModalViewControllerWithLastState:poppedModalState];
    });
}

- (void)dismissModalViewControllerWithLastState:(OXMModalState *)lastModalState {
    @weakify(self);
    [self dismissModalOnceAnimated:YES completionHandler:^{
        @strongify(self);
        self.modalViewController = nil;
        if (lastModalState.onStatePopFinished != nil) {
            lastModalState.onStatePopFinished(lastModalState);
        }
    }];
}

- (void)display:(OXMModalState *)state fromRootViewController:(UIViewController *)fromRootViewController animated:(BOOL)animated completionHandler:(nullable OXMVoidBlock)completionHandler {
    
    if (!state) {
        OXMLogError(@"Undefined state");
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        // Step 1: If modalViewController doesn't exist, create one and show it
        if (!self.modalViewController) {
            [self createModalViewControllerWithState:state];
            if (!self.modalViewController) {
                OXMLogError(@"Unable to create an InterstitialViewController");
                return;
            }
            
            if (!fromRootViewController) {
                OXMLogError(@"No root VC to present from");
                return;
            }
            
            [self.delegate modalManagerWillPresentModal];
            [fromRootViewController presentViewController:self.modalViewController animated:animated completion:nil];
        }
        
        // Verifying type of modalViewController
        else if (state.mraidState == OXMMRAIDStateResized && ![self.modalViewController isMemberOfClass:[OXMNonModalViewController class]]) {
            UIViewController *rootVC = self.modalViewController.presentingViewController;
            [self dismissModalOnceAnimated:YES completionHandler:^{
                @strongify(self);
                self.modalViewController = nil;
                [self display:state fromRootViewController:rootVC animated:NO completionHandler:completionHandler];
            }];
            return;
        }
        else if (state.mraidState != OXMMRAIDStateResized && [self.modalViewController isMemberOfClass:[OXMNonModalViewController class]]) {
            UIViewController *rootVC = self.modalViewController.presentingViewController;
            [self dismissModalOnceAnimated:YES completionHandler:^{
                @strongify(self);
                self.modalViewController = nil;
                [self display:state fromRootViewController:rootVC animated:animated completionHandler:completionHandler];
            }];
            return;
        }
        else if (state.mraidState == OXMMRAIDStateResized && [self.modalViewController isMemberOfClass:[OXMNonModalViewController class]]) {
            UIPresentationController *presenter = self.modalViewController.presentationController;
            if ([presenter isMemberOfClass:[OXMModalPresentationController class]]) {
                OXMModalPresentationController *modalPresenter = (OXMModalPresentationController *)presenter;
                modalPresenter.frameOfPresentedView = state.displayProperties.contentFrame;
                [modalPresenter containerViewWillLayoutSubviews];
            }
        }
        
        // Step 2: setup the current modal state
        [self.modalViewController setupState:state];
        
        // Step 3: run completion if any
        if (completionHandler) {
            completionHandler();
        }
    });
}

- (void)hideModalAnimated:(BOOL)animated completionHandler:(OXMVoidBlock)completionHandler {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.modalViewController) {
            [self dismissModalOnceAnimated:animated completionHandler:completionHandler];
        }
        else if (completionHandler) {
            completionHandler();
        }
    });

}

- (void)dismissModalOnceAnimated:(BOOL)animated completionHandler:(OXMVoidBlock)completionHandler {
    if (self.isModalDismissing || !self.modalViewController) {
        return;
    }
    self.isModalDismissing = YES;
    @weakify(self);
    const BOOL isLastState = self.modalStateStack.count == 0;
    [self.modalViewController dismissViewControllerAnimated:animated completion:^{
        @strongify(self);
        self.isModalDismissing = NO;
        if (isLastState) {
            [self.delegate modalManagerDidDismissModal];
        }
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)backModalAnimated:(BOOL)animated fromRootViewController:(UIViewController *)fromRootViewController completionHandler:(OXMVoidBlock)completionHandler {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self.modalViewController && fromRootViewController) {
            [fromRootViewController presentViewController:self.modalViewController animated:animated completion:completionHandler];
        }
        else if (completionHandler) {
            completionHandler();
        }
    });
}

//TODO: Consider moving to OXMAbstractCreative
#pragma mark - OXMModalViewControllerDelegate

- (void)modalViewControllerCloseButtonTapped:(OXMModalViewController *)modalViewController {
    [self removeModal:modalViewController.modalState];
}

// notify delegate that control has transferred to another app.
- (void)modalViewControllerDidLeaveApp {
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);

        for (OXMModalState *state in [[self.modalStateStack reverseObjectEnumerator] allObjects]) {
            if (state.onStateHasLeftApp != nil) {
                state.onStateHasLeftApp(state);
            }
        }
        
        // close the interstitial *after* all the interstitials have been notified above.
        [self modalViewControllerCloseButtonTapped:self.modalViewController];
    });
}

#pragma mark - Helper Methods

- (void)createModalViewControllerWithState:(OXMModalState *)state {
    
    if (self.modalViewControllerClass) {
        self.modalViewController = [self.modalViewControllerClass new];
    }
    else if ([state.mraidState isEqualToString:OXMMRAIDStateResized]) {
        self.modalViewController = [[OXMNonModalViewController alloc] initWithFrameOfPresentedView:state.displayProperties.contentFrame];
    }
    else {
        self.modalViewController = [OXMModalViewController new];
        self.modalViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    
    self.modalViewController.rotationEnabled = state.rotationEnabled;
    self.modalViewController.modalManager = self;
    self.modalViewController.modalViewControllerDelegate = self;
}

@end
