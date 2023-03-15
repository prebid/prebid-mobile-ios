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

#import "PBMModalManager.h"

#import "PBMVideoView.h"
#import "PBMDownloadDataHelper.h"
#import "PBMAbstractCreative.h"
#import "PBMFunctions+Private.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMModalPresentationController.h"
#import "PBMModalViewController.h"
#import "PBMNonModalViewController.h"
#import "PBMModalViewControllerDelegate.h"
#import "PBMModalState.h"
#import "PBMDeferredModalState.h"
#import "PBMMacros.h"
#import "PBMModalAnimator.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Constants

static NSString * const PBMInterstitialStoryboardName  = @"Interstitial";

#pragma mark - Private Interface

@interface PBMModalManager()

@property (nonatomic,weak,nullable) id<PBMModalManagerDelegate> delegate;

@property (nonatomic,assign,readwrite) BOOL isModalDismissing;
@property (nonatomic,strong,nullable) PBMDeferredModalState *deferredModalState;

//The last item in this stack represents the view & display properties currently being displayed.
@property (nonatomic, strong, nonnull) NSMutableArray<PBMModalState *> *modalStateStack;

@end

#pragma mark - Implementation

@implementation PBMModalManager

#pragma mark - Initialization

- (instancetype)init {
    return (self = [self initWithDelegate:nil]);
}

- (instancetype)initWithDelegate:(nullable id<PBMModalManagerDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _modalStateStack = [[NSMutableArray alloc] init];
    _delegate = delegate;
    return self;
}

- (void) dealloc {
    if (_modalViewController) {
        __weak id<PBMModalManagerDelegate> delegate = _delegate;
        [_modalViewController dismissViewControllerAnimated:true completion:^{
            [delegate modalManagerDidDismissModal];
        }];
    }
}

-(NSString *)pbmDescription:(UIInterfaceOrientation)orientation {
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
        if (!self) { return; }
        
        PBMLogInfo(@"Forcing orientation to %@", [self pbmDescription:forcedOrientation]);
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: forcedOrientation] forKey:@"orientation"];
    });
}

- (void)creativeDisplayCompleted:(PBMAbstractCreative*)creative {
    [self.modalViewController creativeDisplayCompleted:creative];
}

#pragma mark - External API

- (PBMVoidBlock)pushModal:(PBMModalState *)state
   fromRootViewController:(UIViewController *)fromRootViewController
                 animated:(BOOL)animated
            shouldReplace:(BOOL)shouldReplace
        completionHandler:(PBMVoidBlock)completionHandler {
    
    PBMAssert(state && fromRootViewController);
    if (!(state && fromRootViewController)) {
        PBMLogError(@"Invalid input parameters");
        return nil;
    }
    
    if (self.deferredModalState != nil) {
        if (state != self.deferredModalState.modalState) {
            PBMLogError(@"Attempting to push modal state while another deferred state is being prepared");
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

- (void)pushDeferredModal:(nonnull PBMDeferredModalState *)deferredModalState {
    if (self.deferredModalState == nil && !self.isModalDismissing) {
        self.deferredModalState = deferredModalState;
        @weakify(self);
        __weak PBMDeferredModalState *weakDeferredState = deferredModalState;
        [deferredModalState prepareAndPushWithModalManager:self discardBlock:^{
            @strongify(self);
            if (!self) { return; }
            
            if (self.deferredModalState != nil && self.deferredModalState == weakDeferredState) {
                self.deferredModalState = nil;
            }
        }];
    }
}

- (nonnull PBMVoidBlock)removeStateBlock:(PBMModalState *)modalState {
    PBMModalState * __weak weakModalState = modalState;
    @weakify(self);
    return ^{
        @strongify(self);
        if (!self) { return; }
        
        PBMModalState * const removedState = weakModalState;
        if (removedState) {
            [self removeModal:removedState];
        }
    };
}

- (void)removeModal:(nonnull PBMModalState *)modalState {
    PBMModalState *activeState = [self.modalStateStack lastObject];
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
        PBMModalState *poppedModalState = [self.modalStateStack lastObject];
        if (!poppedModalState) {
            PBMLogError(@"popModal called on empty modalStateStack!");
            return;
        }
                
        [self.modalStateStack removeLastObject];

        //Was that the last modal in the stack?
        PBMModalState *state = [self.modalStateStack lastObject];
        if (state) {
            //There's still at least one left.
            //We need force orientation once again
            if (state.displayProperties.interstitialLayout == PBMInterstitialLayoutLandscape) {
                [self forceOrientation:UIInterfaceOrientationLandscapeLeft];
            } else if (state.displayProperties.interstitialLayout == PBMInterstitialLayoutPortrait) {
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
        if (!self) { return; }
        
        PBMModalState *poppedModalState = [self.modalStateStack lastObject];
        [self.modalStateStack removeAllObjects];
        [self dismissModalViewControllerWithLastState:poppedModalState];
    });
}

- (void)dismissModalViewControllerWithLastState:(PBMModalState *)lastModalState {
    @weakify(self);
    [self dismissModalOnceAnimated:YES completionHandler:^{
        @strongify(self);
        if (!self) { return; }
        
        self.modalViewController = nil;
        if (lastModalState.onStatePopFinished != nil) {
            lastModalState.onStatePopFinished(lastModalState);
        }
    }];
}

- (void)display:(PBMModalState *)state fromRootViewController:(UIViewController *)fromRootViewController animated:(BOOL)animated completionHandler:(nullable PBMVoidBlock)completionHandler {
    
    if (!state) {
        PBMLogError(@"Undefined state");
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        // Step 1: If modalViewController doesn't exist, create one and show it
        if (!self.modalViewController) {
            [self createModalViewControllerWithState:state];
            if (!self.modalViewController) {
                PBMLogError(@"Unable to create an InterstitialViewController");
                return;
            }
            
            if (!fromRootViewController) {
                PBMLogError(@"No root VC to present from");
                return;
            }
            
            [self.delegate modalManagerWillPresentModal];
            [fromRootViewController presentViewController:self.modalViewController animated:animated completion:nil];
        }
        
        // Verifying type of modalViewController
        else if (state.mraidState == PBMMRAIDStateResized && ![self.modalViewController isMemberOfClass:[PBMNonModalViewController class]]) {
            UIViewController *rootVC = self.modalViewController.presentingViewController;
            [self dismissModalOnceAnimated:YES completionHandler:^{
                @strongify(self);
                self.modalViewController = nil;
                [self display:state fromRootViewController:rootVC animated:NO completionHandler:completionHandler];
            }];
            return;
        }
        else if (state.mraidState != PBMMRAIDStateResized && [self.modalViewController isMemberOfClass:[PBMNonModalViewController class]]) {
            UIViewController *rootVC = self.modalViewController.presentingViewController;
            [self dismissModalOnceAnimated:YES completionHandler:^{
                @strongify(self);
                if (!self) { return; }
                self.modalViewController = nil;
                [self display:state fromRootViewController:rootVC animated:animated completionHandler:completionHandler];
            }];
            return;
        }
        else if (state.mraidState == PBMMRAIDStateResized && [self.modalViewController isMemberOfClass:[PBMNonModalViewController class]]) {
            UIPresentationController *presenter = self.modalViewController.presentationController;
            if ([presenter isMemberOfClass:[PBMModalPresentationController class]]) {
                PBMModalPresentationController *modalPresenter = (PBMModalPresentationController *)presenter;
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

- (void)hideModalAnimated:(BOOL)animated completionHandler:(PBMVoidBlock)completionHandler {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        if (self.modalViewController) {
            [self dismissModalOnceAnimated:animated completionHandler:completionHandler];
        }
        else if (completionHandler) {
            completionHandler();
        }
    });

}

- (void)dismissModalOnceAnimated:(BOOL)animated completionHandler:(PBMVoidBlock)completionHandler {
    if (self.isModalDismissing || !self.modalViewController) {
        return;
    }
    self.isModalDismissing = YES;
    @weakify(self);
    const BOOL isLastState = self.modalStateStack.count == 0;
    [self.modalViewController dismissViewControllerAnimated:animated completion:^{
        @strongify(self);
        if (!self) { return; }
        
        self.isModalDismissing = NO;
        if (isLastState) {
            [self.delegate modalManagerDidDismissModal];
        }
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)backModalAnimated:(BOOL)animated fromRootViewController:(UIViewController *)fromRootViewController completionHandler:(PBMVoidBlock)completionHandler {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self) { return; }
        
        if (self.modalViewController && fromRootViewController) {
            [fromRootViewController presentViewController:self.modalViewController animated:animated completion:completionHandler];
        }
        else if (completionHandler) {
            completionHandler();
        }
    });
}

//TODO: Consider moving to PBMAbstractCreative
#pragma mark - PBMModalViewControllerDelegate

- (void)modalViewControllerCloseButtonTapped:(PBMModalViewController *)modalViewController {
    [self removeModal:modalViewController.modalState];
}

// notify delegate that control has transferred to another app.
- (void)modalViewControllerDidLeaveApp {
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);

        if (!self) { return; }
        
        for (PBMModalState *state in [[self.modalStateStack reverseObjectEnumerator] allObjects]) {
            if (state.onStateHasLeftApp != nil) {
                state.onStateHasLeftApp(state);
            }
        }
        
        // close the interstitial *after* all the interstitials have been notified above.
        [self modalViewControllerCloseButtonTapped:self.modalViewController];
    });
}

#pragma mark - Helper Methods

- (void)createModalViewControllerWithState:(PBMModalState *)state {
    
    if (self.modalViewControllerClass) {
        self.modalViewController = [self.modalViewControllerClass new];
    }
    else if ([state.mraidState isEqualToString:PBMMRAIDStateResized]) {
        self.modalViewController = [[PBMNonModalViewController alloc] initWithFrameOfPresentedView:state.displayProperties.contentFrame];
    }
    else {
        self.modalViewController = [PBMModalViewController new];
        self.modalViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    
    self.modalViewController.rotationEnabled = state.rotationEnabled;
    self.modalViewController.modalManager = self;
    self.modalViewController.modalViewControllerDelegate = self;
}

@end
