//
//  OXMUIApplicationProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//


//Since only one UIApplication can exist at a time it can only be "mocked" by applying a protocol
//to it that it already conforms to.

#import <UIKit/UIKit.h>

@protocol OXMUIApplicationProtocol

@property (nonatomic, assign) BOOL isStatusBarHidden;
@property (nonatomic, assign) UIInterfaceOrientation statusBarOrientation;
@property (nonatomic, assign, readonly) CGRect statusBarFrame;

- (BOOL)openURL:(nonnull NSURL*)url NS_DEPRECATED_IOS(2_0, 10_0, "Please use openURL:options:completionHandler: instead") NS_EXTENSION_UNAVAILABLE_IOS("");
- (void)openURL:(nonnull NSURL*)url options:(nullable NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion NS_AVAILABLE_IOS(10_0) NS_EXTENSION_UNAVAILABLE_IOS("");

@end

//Apply the protocol to UIApplication
@interface UIApplication (OXMUIApplicationProtocol) <OXMUIApplicationProtocol>
@end

@implementation UIApplication (OXMUIApplicationProtocol)
@dynamic isStatusBarHidden;
@end
