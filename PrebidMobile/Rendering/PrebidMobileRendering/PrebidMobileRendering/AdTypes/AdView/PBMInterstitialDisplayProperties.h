//
//  PBMInterstitialDisplayProperties.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBMInterstitialLayout.h"

typedef NS_ENUM(NSInteger, PBMPosition) {
    PBMPositionUndefined    NS_SWIFT_NAME(undefined) = -1,
    PBMPositionTopLeft      NS_SWIFT_NAME(topLeft),
    PBMPositionTopCenter    NS_SWIFT_NAME(topCenter),
    PBMPositionTopRight     NS_SWIFT_NAME(topRight),
    PBMPositionCenter       NS_SWIFT_NAME(center),
    PBMPositionBottomLeft   NS_SWIFT_NAME(bottomLeft),
    PBMPositionBottomCenter NS_SWIFT_NAME(bottomCenter),
    PBMPositionBottomRight  NS_SWIFT_NAME(bottomRight),
    PBMPositionCustom       NS_SWIFT_NAME(custom)
};

NS_ASSUME_NONNULL_BEGIN
@interface PBMInterstitialDisplayProperties : NSObject <NSCopying>

@property (nonatomic, assign) NSTimeInterval closeDelay;
@property (nonatomic, assign) NSTimeInterval closeDelayLeft; // The time interval that left from @closeDelay in case of interruption
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, strong) UIColor *contentViewColor;
@property (nonatomic, readonly, getter=isRotationEnabled) BOOL rotationEnabled;
@property (nonatomic, assign) PBMInterstitialLayout interstitialLayout;

- (void)setButtonImageHidden;
- (nullable UIImage *)getCloseButtonImage;

@end
NS_ASSUME_NONNULL_END
