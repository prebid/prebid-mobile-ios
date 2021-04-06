//
//  UIWindow+OxmExtensions.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

//TODO: Replace with a passed-in VC
@interface UIWindow (OxmExtensions)

+ (nullable UIViewController *)appVisibleViewController;

- (nullable UIViewController *)visibleViewController;

@end
