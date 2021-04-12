//
//  OXMModalViewControllerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMModalViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol OXMModalViewControllerDelegate <NSObject>
- (void)modalViewControllerCloseButtonTapped:(OXMModalViewController *)modalViewController;
- (void)modalViewControllerDidLeaveApp;
@end

NS_ASSUME_NONNULL_END
