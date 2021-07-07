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

