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

#import "PBMWindowLocker.h"
#import <UIKit/UIKit.h>
#import "PBMOpenMeasurementSession.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface PBMWindowLocker ()
@property (nonatomic, assign, readwrite, getter=isLocked) BOOL locked;
@property (nonatomic, weak, nullable, readonly) UIWindow *window;
@property (nonatomic, weak, readonly) PBMOpenMeasurementSession *measurementSession;
@property (nonatomic, weak, nullable, readwrite) UIView *lockingView;
@end

// MARK: -

@implementation PBMWindowLocker

- (instancetype)initWithWindow:(UIWindow *)window measurementSession:(PBMOpenMeasurementSession *)measurementSession {
    if (!(self = [super init])) {
        return nil;
    }
    _window = window;
    _measurementSession = measurementSession;
    return self;
}

- (void)lock {
    if (self.locked) {
        PBMLogError(@"Attempting to lock already locked window locker.");
        return;
    }
    UIView * lockingView = [self lockingView] ?: [self buildLockingView];
    if (lockingView == nil) {
        PBMLogError(@"Failed to create window locking view.");
        return;
    }
    self.lockingView = lockingView;
    [self.window addSubview:lockingView];
    [self.window addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.window attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.lockingView attribute:NSLayoutAttributeWidth multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.window attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.lockingView attribute:NSLayoutAttributeHeight multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.window attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.lockingView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.window attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.lockingView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
    ]];
    
    self.locked = YES;
}

- (void)unlock {
    if (!self.locked) {
        PBMLogError(@"Attempting to unlock already unlocked window locker.");
        return;
    }
    [self.lockingView removeFromSuperview];
    self.locked = NO;
}

- (UIView *)buildLockingView {
    if (self.window == nil) {
        return nil;
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.window.bounds];
    UIActivityIndicatorViewStyle indicatorStyle;
    if (@available(iOS 13.0, *)) {
        indicatorStyle = UIActivityIndicatorViewStyleLarge;
    } else {
        indicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    }
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
    [activityIndicatorView startAnimating];
    
    [backgroundView addSubview:activityIndicatorView];
    [backgroundView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:activityIndicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:activityIndicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
    ]];
    
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // FIXME: Customize dark appearance
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    activityIndicatorView.color = [UIColor whiteColor];
    
    [self.measurementSession addFriendlyObstruction:backgroundView purpose:PBMOpenMeasurementFriendlyObstructionWindowLockerBackground];
    [self.measurementSession addFriendlyObstruction:activityIndicatorView purpose:PBMOpenMeasurementFriendlyObstructionWindowLockerActivityIndicator];
    
    return backgroundView;
}

@end
