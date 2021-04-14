//
//  OXMNonModalViewController.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMNonModalViewController.h"
#import "OXMFunctions+Private.h"
#import "UIView+OxmExtensions.h"
#import "OXMModalAnimator.h"

@interface OXMNonModalViewController ()

@property (nonatomic, strong) OXMModalAnimator *modalAnimator;

@end

@implementation OXMNonModalViewController

- (instancetype)initWithFrameOfPresentedView:(CGRect)frameOfPresentedView {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        
        self.modalAnimator = [[OXMModalAnimator alloc] initWithFrameOfPresentedView:frameOfPresentedView];
        self.transitioningDelegate = self.modalAnimator;

        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)configureDisplayView {    
    OXMInterstitialDisplayProperties *props = self.displayProperties;
    self.contentView.backgroundColor = props.contentViewColor;
    self.displayView.backgroundColor = [UIColor clearColor];
    
    CGRect contentFrame = CGRectMake(0, 0, props.contentFrame.size.width, props.contentFrame.size.height);
    [self.displayView OXMAddConstraintsFromCGRect: contentFrame];
}

@end
