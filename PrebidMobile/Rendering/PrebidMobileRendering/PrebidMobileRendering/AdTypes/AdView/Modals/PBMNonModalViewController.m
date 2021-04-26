//
//  PBMNonModalViewController.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMNonModalViewController.h"
#import "PBMFunctions+Private.h"
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
