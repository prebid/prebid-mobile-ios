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

#import "UIWindow+PBMExtensions.h"

@implementation UIWindow (PBMExtensions)

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
