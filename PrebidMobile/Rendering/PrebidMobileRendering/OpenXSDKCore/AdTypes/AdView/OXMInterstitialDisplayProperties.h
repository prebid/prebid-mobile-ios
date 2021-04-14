//
//  OXMInterstitialDisplayProperties.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMInterstitialLayout.h"

typedef NS_ENUM(NSInteger, OXMPosition) {
    OXMPositionUndefined    NS_SWIFT_NAME(undefined) = -1,
    OXMPositionTopLeft      NS_SWIFT_NAME(topLeft),
    OXMPositionTopCenter    NS_SWIFT_NAME(topCenter),
    OXMPositionTopRight     NS_SWIFT_NAME(topRight),
    OXMPositionCenter       NS_SWIFT_NAME(center),
    OXMPositionBottomLeft   NS_SWIFT_NAME(bottomLeft),
    OXMPositionBottomCenter NS_SWIFT_NAME(bottomCenter),
    OXMPositionBottomRight  NS_SWIFT_NAME(bottomRight),
    OXMPositionCustom       NS_SWIFT_NAME(custom)
};

NS_ASSUME_NONNULL_BEGIN
@interface OXMInterstitialDisplayProperties : NSObject <NSCopying>

@property (nonatomic, assign) NSTimeInterval closeDelay;
@property (nonatomic, assign) NSTimeInterval closeDelayLeft; // The time interval that left from @closeDelay in case of interruption
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, strong) UIColor *contentViewColor;
@property (nonatomic, readonly, getter=isRotationEnabled) BOOL rotationEnabled;
@property (nonatomic, assign) OXMInterstitialLayout interstitialLayout;

- (void)setButtonImageHidden;
- (nullable UIImage *)getCloseButtonImage;

@end
NS_ASSUME_NONNULL_END
