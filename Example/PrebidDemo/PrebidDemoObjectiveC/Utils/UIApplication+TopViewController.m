/*   Copyright 2019-2024 Prebid.org, Inc.
 
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

#import "UIApplication+TopViewController.h"

@implementation UIApplication (TopViewController)

- (UIViewController * _Nullable)topViewController {
    UIWindow *keyWindow = nil;
    
    for (UIScene *scene in self.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
        }
        if (keyWindow) break;
    }
    
    if (!keyWindow) {
        return nil;
    }
    
    UIViewController *rootViewController = keyWindow.rootViewController;
    if (!rootViewController) {
        return nil;
    }
    
    return [self findTopMostViewControllerFrom:rootViewController];
}

- (UIViewController *)findTopMostViewControllerFrom:(UIViewController *)viewController {
    if (viewController.presentedViewController) {
        return [self findTopMostViewControllerFrom:viewController.presentedViewController];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self findTopMostViewControllerFrom:navigationController.visibleViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self findTopMostViewControllerFrom:tabBarController.selectedViewController];
    }
    
    return viewController;
}

@end
