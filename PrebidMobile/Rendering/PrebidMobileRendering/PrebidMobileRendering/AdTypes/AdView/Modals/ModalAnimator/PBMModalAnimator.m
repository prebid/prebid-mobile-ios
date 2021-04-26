//
//  PBMModalAnimator.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMModalAnimator.h"
#import "PBMModalPresentationController.h"

@interface PBMModalAnimator()

@property (nonatomic, weak) PBMModalPresentationController *modalPresentationController;

@property (nonatomic, assign) CGRect frameOfPresentedView;
@property (nonatomic, assign) BOOL isPresented;

@end

#pragma mark - Implemetnation

@implementation PBMModalAnimator

- (instancetype)initWithFrameOfPresentedView:(CGRect)frameOfPresentedView; {
    self = [super init];
    if (self) {
        self.frameOfPresentedView = frameOfPresentedView;
        self.isPresented = NO;
    }
    
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.isPresented = YES;
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.isPresented = NO;
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    self.isPresented = YES;
    
    PBMModalPresentationController *modalPresentationController = [[PBMModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting ?: source];
    modalPresentationController.frameOfPresentedView = self.frameOfPresentedView;
    self.modalPresentationController = modalPresentationController;
    
    return modalPresentationController;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (void)animationEnded:(BOOL)transitionCompleted {
    self.isPresented = NO;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.isPresented) {
        [[transitionContext containerView] addSubview:toViewController.view];
        toViewController.view.alpha = 0.0;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end

