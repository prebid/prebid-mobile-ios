//
//  PBMModalViewControllerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMModalViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMModalViewControllerDelegate <NSObject>
- (void)modalViewControllerCloseButtonTapped:(PBMModalViewController *)modalViewController;
- (void)modalViewControllerDidLeaveApp;
@end

NS_ASSUME_NONNULL_END
