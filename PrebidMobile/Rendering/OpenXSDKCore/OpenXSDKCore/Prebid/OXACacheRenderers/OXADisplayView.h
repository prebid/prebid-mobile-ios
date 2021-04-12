//
//  OXADisplayView.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXADisplayViewLoadingDelegate.h"
#import "OXADisplayViewInteractionDelegate.h"

@class OXABid;

NS_ASSUME_NONNULL_BEGIN

@interface OXADisplayView : UIView

@property (atomic, weak, nullable) id<OXADisplayViewLoadingDelegate> loadingDelegate;
@property (atomic, weak, nullable) id<OXADisplayViewInteractionDelegate> interactionDelegate;
@property (nonatomic, readonly) BOOL isCreativeOpened;

- (instancetype)initWithFrame:(CGRect)frame bid:(OXABid *)bid configId:(NSString *)configId;

- (void)displayAd;

@end

NS_ASSUME_NONNULL_END
