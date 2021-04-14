//
//  OXMWindowLocker.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMWindowLocker.h"
#import <UIKit/UIKit.h>
#import "OXMOpenMeasurementSession.h"
#import "OXMMacros.h"

@interface OXMWindowLocker ()
@property (nonatomic, assign, readwrite, getter=isLocked) BOOL locked;
@property (nonatomic, weak, nullable, readonly) UIWindow *window;
@property (nonatomic, weak, readonly) OXMOpenMeasurementSession *measurementSession;
@property (nonatomic, weak, nullable, readwrite) UIView *lockingView;
@end

// MARK: -

@implementation OXMWindowLocker

- (instancetype)initWithWindow:(UIWindow *)window measurementSession:(OXMOpenMeasurementSession *)measurementSession {
    if (!(self = [super init])) {
        return nil;
    }
    _window = window;
    _measurementSession = measurementSession;
    return self;
}

- (void)lock {
    if (self.locked) {
        OXMLogError(@"Attempting to lock already locked window locker.");
        return;
    }
    UIView * lockingView = [self lockingView] ?: [self buildLockingView];
    if (lockingView == nil) {
        OXMLogError(@"Failed to create window locking view.");
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
        OXMLogError(@"Attempting to unlock already unlocked window locker.");
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
    
    [self.measurementSession addFriendlyObstruction:backgroundView purpose:OXMOpenMeasurementFriendlyObstructionWindowLockerBackground];
    [self.measurementSession addFriendlyObstruction:activityIndicatorView purpose:OXMOpenMeasurementFriendlyObstructionWindowLockerActivityIndicator];
    
    return backgroundView;
}

@end
