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

#import "PBMLegalButtonDecorator.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"
#import "PBMModalManager.h"
#import "PBMClickthroughBrowserView.h"
#import "PBMModalState.h"
#import "PBMAdConfiguration.h"
#import "PBMVideoCreative.h"

NSString * const PBMPrivacyPolicyUrlString = @"https://www.openx.com/legal/privacy-policy/";

typedef NS_ENUM(NSInteger, PBMLegalButtonType) {
    PBMLegalButtonTypeMinimized,
    PBMLegalButtonTypeExpanded
};

#pragma mark - Private Interface

@interface PBMLegalButtonDecorator ()

@property (nonatomic, assign) PBMLegalButtonType legalButtonType;

@end

#pragma mark - Implementation

@implementation PBMLegalButtonDecorator

#pragma mark - Initialization

- (instancetype)initWithPosition:(PBMPosition)position {
    self = [super init];
    if (self) {
        
        self.buttonPosition = position;
        self.legalButtonType = PBMLegalButtonTypeMinimized;
        self.button.accessibilityIdentifier = @"PBM legalButton";
        
        UIImage *collapsedImage = [self imageWithType:self.legalButtonType position:self.buttonPosition];
        [self setImage:collapsedImage];
    }
    return self;
}

- (nullable PBMClickthroughBrowserView *)clickthroughBrowserView {
    NSURL *url = [NSURL URLWithString:PBMPrivacyPolicyUrlString];
    PBMClickthroughBrowserView *clickthroughBrowserView = [[PBMFunctions.bundleForSDK loadNibNamed:@"ClickthroughBrowserView" owner:nil options:nil] firstObject];
    if (!clickthroughBrowserView) {
        PBMLogError(@"Unable to create a ClickthroughBrowserView");
        return nil;
    }
    [clickthroughBrowserView openURL:url completion:nil];
    
    return clickthroughBrowserView;
}


- (NSInteger)getButtonConstraintConstant {
    return 0;
}

- (void)setButtonPosition:(PBMPosition)buttonPosition {
    [super setButtonPosition:buttonPosition];
    UIImage *collapsedImage = [self imageWithType:self.legalButtonType position:self.buttonPosition];
    [self setImage:collapsedImage];
}

- (void)buttonTappedAction {
    if (self.legalButtonType == PBMLegalButtonTypeExpanded) {
        if (self.buttonTouchUpInsideBlock) {
            self.buttonTouchUpInsideBlock();
        }
    } else {
        self.legalButtonType = PBMLegalButtonTypeExpanded;
        UIImage *expandedImage = [self imageWithType:self.legalButtonType position:self.buttonPosition];
        [self setImage:expandedImage];
        [self updateButtonConstraints];
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.button layoutIfNeeded];
        }];
    }
}

- (UIImage *)imageWithType:(PBMLegalButtonType)type position:(PBMPosition)position {
    NSMutableString *imageNamed = [NSMutableString stringWithString:@"adchoices"];
    
    switch (type) {
        case PBMLegalButtonTypeMinimized:
            [imageNamed appendString:@"-collapsed"];
            break;
        case PBMLegalButtonTypeExpanded:
            [imageNamed appendString:@"-expanded"];
            break;
    }
    
    switch (position) {
        case PBMPositionTopRight:
            [imageNamed appendString:@"-top-right"];
            break;
        default:
            [imageNamed appendString:@"-bottom-right"];
            break;
    }
    
    return [UIImage imageNamed:imageNamed inBundle:[PBMFunctions bundleForSDK] compatibleWithTraitCollection:nil];
}

@end
