//
//  OXMModalPresentationController.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMModalPresentationController.h"
#import "OXMTouchForwardingView.h"

@interface OXMModalPresentationController ()

@property (strong, nonatomic) OXMTouchForwardingView *touchForwardingView;

@end

#pragma mark - Implementation

@implementation OXMModalPresentationController

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    
    if (self.containerView) {
        [self.touchForwardingView removeFromSuperview];
        self.touchForwardingView = [[OXMTouchForwardingView alloc] initWithFrame:self.containerView.bounds];
        self.touchForwardingView.passThroughViews = @[self.presentingViewController.view];
        [self.containerView insertSubview:self.touchForwardingView atIndex:0];
    }
}

- (void)containerViewWillLayoutSubviews {
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    
    if (self.containerView && self.touchForwardingView) {
        self.touchForwardingView.frame = self.containerView.bounds;
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    return self.frameOfPresentedView;
}

@end
