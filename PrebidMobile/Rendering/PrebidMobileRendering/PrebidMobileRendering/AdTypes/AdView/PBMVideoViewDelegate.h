//
//  PBMVideoViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

// This protocol allows the VideoView to communicate events out to whatever is using one
NS_ASSUME_NONNULL_BEGIN
@protocol PBMVideoViewDelegate <NSObject>

- (void)videoViewFailedWithError:(NSError *)error;

- (void)videoViewReadyToDisplay;
- (void)videoViewCompletedDisplay;
- (void)videoViewWasTapped;

- (void)learnMoreWasClicked;

@end
NS_ASSUME_NONNULL_END
