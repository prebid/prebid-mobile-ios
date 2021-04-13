//
//  UIWindow+OxmExtensions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "UIWindow+OxmExtensions.h"

@implementation UIWindow (OxmExtensions)

+ (nullable UIViewController *)appVisibleViewController {
    UIWindow *win = UIApplication.sharedApplication.keyWindow;
    UIViewController *ret = [win visibleViewController];
    
    return ret;
}

- (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    if (rootViewController) {
        return [UIWindow getVisibleViewControllerFrom:rootViewController];
    }
    
    return nil;
}

+ (nullable UIViewController *)getVisibleViewControllerFrom:(nonnull UIViewController *) vc {
    if (!vc) {
        return nil;
    }
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)vc;
        
        //Recursion
        return [UIWindow getVisibleViewControllerFrom:navigationController.visibleViewController];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)vc;
        
        //Recursion
        return [UIWindow getVisibleViewControllerFrom:tabBarController.selectedViewController];
    }
    //It's a VC
    //Is it presenting another VC?
    UIViewController *presentedViewConroller = vc.presentedViewController;
    if (presentedViewConroller) {
        return [UIWindow getVisibleViewControllerFrom:presentedViewConroller];
    }
        
    return vc;
}

@end
