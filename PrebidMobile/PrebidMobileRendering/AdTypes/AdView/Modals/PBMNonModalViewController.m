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

#import "PBMFunctions+Private.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMNonModalViewController.h"
#import "UIView+PBMExtensions.h"
#import "PBMModalAnimator.h"

@interface PBMNonModalViewController ()

@property (nonatomic, strong) PBMModalAnimator *modalAnimator;

@end

@implementation PBMNonModalViewController

- (instancetype)initWithFrameOfPresentedView:(CGRect)frameOfPresentedView {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        
        self.modalAnimator = [[PBMModalAnimator alloc] initWithFrameOfPresentedView:frameOfPresentedView];
        self.transitioningDelegate = self.modalAnimator;

        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)configureDisplayView {    
    PBMInterstitialDisplayProperties *props = self.displayProperties;
    self.contentView.backgroundColor = props.contentViewColor;
    self.displayView.backgroundColor = [UIColor clearColor];
    
    CGRect contentFrame = CGRectMake(0, 0, props.contentFrame.size.width, props.contentFrame.size.height);
    [self.displayView PBMAddConstraintsFromCGRect: contentFrame];
}

@end
