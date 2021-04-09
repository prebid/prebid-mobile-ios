//
//  OXMLegalButtonDecorator.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMLegalButtonDecorator.h"
#import "OXMFunctions+Private.h"
#import "OXMMacros.h"
#import "OXMModalManager.h"
#import "OXMClickthroughBrowserView.h"
#import "OXMModalState.h"
#import "OXMAdConfiguration.h"
#import "OXMVideoCreative.h"

NSString * const OXMPrivacyPolicyUrlString = @"https://www.openx.com/legal/privacy-policy/";

typedef NS_ENUM(NSInteger, OXMLegalButtonType) {
    OXMLegalButtonTypeMinimized,
    OXMLegalButtonTypeExpanded
};

#pragma mark - Private Interface

@interface OXMLegalButtonDecorator ()

@property (nonatomic, assign) OXMLegalButtonType legalButtonType;

@end

#pragma mark - Implementation

@implementation OXMLegalButtonDecorator

#pragma mark - Initialization

- (instancetype)initWithPosition:(OXMPosition)position {
    self = [super init];
    if (self) {
        
        self.buttonPosition = position;
        self.legalButtonType = OXMLegalButtonTypeMinimized;
        self.button.accessibilityIdentifier = @"OXM legalButton";
        
        UIImage *collapsedImage = [self imageWithType:self.legalButtonType position:self.buttonPosition];
        [self setImage:collapsedImage];
    }
    return self;
}

- (nullable OXMClickthroughBrowserView *)clickthroughBrowserView {
    NSURL *url = [NSURL URLWithString:OXMPrivacyPolicyUrlString];
    OXMClickthroughBrowserView *clickthroughBrowserView = [[OXMFunctions.bundleForSDK loadNibNamed:@"ClickthroughBrowserView" owner:nil options:nil] firstObject];
    if (!clickthroughBrowserView) {
        OXMLogError(@"Unable to create a ClickthroughBrowserView");
        return nil;
    }
    [clickthroughBrowserView openURL:url completion:nil];
    
    return clickthroughBrowserView;
}


- (NSInteger)getButtonConstraintConstant {
    return 0;
}

- (void)setButtonPosition:(OXMPosition)buttonPosition {
    [super setButtonPosition:buttonPosition];
    UIImage *collapsedImage = [self imageWithType:self.legalButtonType position:self.buttonPosition];
    [self setImage:collapsedImage];
}

- (void)buttonTappedAction {
    if (self.legalButtonType == OXMLegalButtonTypeExpanded) {
        if (self.buttonTouchUpInsideBlock) {
            self.buttonTouchUpInsideBlock();
        }
    } else {
        self.legalButtonType = OXMLegalButtonTypeExpanded;
        UIImage *expandedImage = [self imageWithType:self.legalButtonType position:self.buttonPosition];
        [self setImage:expandedImage];
        [self updateButtonConstraints];
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.button layoutIfNeeded];
        }];
    }
}

- (UIImage *)imageWithType:(OXMLegalButtonType)type position:(OXMPosition)position {
    NSMutableString *imageNamed = [NSMutableString stringWithString:@"adchoices"];
    
    switch (type) {
        case OXMLegalButtonTypeMinimized:
            [imageNamed appendString:@"-collapsed"];
            break;
        case OXMLegalButtonTypeExpanded:
            [imageNamed appendString:@"-expanded"];
            break;
    }
    
    switch (position) {
        case OXMPositionTopRight:
            [imageNamed appendString:@"-top-right"];
            break;
        default:
            [imageNamed appendString:@"-bottom-right"];
            break;
    }
    
    return [UIImage imageNamed:imageNamed inBundle:[OXMFunctions bundleForSDK] compatibleWithTraitCollection:nil];
}

@end
