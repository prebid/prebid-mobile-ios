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

#import "PBMModalPresentationController.h"
#import "PBMTouchForwardingView.h"

@interface PBMModalPresentationController ()

@property (strong, nonatomic) PBMTouchForwardingView *touchForwardingView;

@end

#pragma mark - Implementation

@implementation PBMModalPresentationController

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    
    if (self.containerView) {
        [self.touchForwardingView removeFromSuperview];
        self.touchForwardingView = [[PBMTouchForwardingView alloc] initWithFrame:self.containerView.bounds];
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
