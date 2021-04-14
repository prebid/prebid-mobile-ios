//
//  OXMMRAIDConstants.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK: MRAID Actions
typedef NSString * _Nonnull OXMMRAIDAction NS_TYPED_ENUM;
// Debug
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionLog;
// MRAID 1
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionOpen;
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionClose;
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionExpand;
// MRAID 2
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionResize;
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionStorePicture;
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionCreateCalendarEvent;
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionPlayVideo;
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionOnOrientationPropertiesChanged;
// MRAID 3
FOUNDATION_EXPORT OXMMRAIDAction const OXMMRAIDActionUnload;
// ---- end MRAID Actions

// mraid enums and structs
typedef NSString * _Nonnull OXMMRAIDPlacementType NS_TYPED_ENUM;
FOUNDATION_EXPORT OXMMRAIDPlacementType const OXMMRAIDPlacementTypeInline;
FOUNDATION_EXPORT OXMMRAIDPlacementType const OXMMRAIDPlacementTypeInterstitial;

typedef NSString * _Nonnull OXMMRAIDFeature NS_TYPED_ENUM;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeatureSMS;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeaturePhone;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeatureCalendar;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeatureSavePicture;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeatureInlineVideo;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeatureLocation;
FOUNDATION_EXPORT OXMMRAIDFeature const OXMMRAIDFeatureVPAID;

//MARK: MRAID Parse Keys
@interface OXMMRAIDParseKeys : NSObject

@property (class, readonly, nonnull) NSString *X                   NS_SWIFT_NAME(X);
@property (class, readonly, nonnull) NSString *Y                   NS_SWIFT_NAME(Y);
@property (class, readonly, nonnull) NSString *WIDTH               NS_SWIFT_NAME(WIDTH);
@property (class, readonly, nonnull) NSString *HEIGHT              NS_SWIFT_NAME(HEIGHT);
@property (class, readonly, nonnull) NSString *X_OFFSET            NS_SWIFT_NAME(X_OFFSET);
@property (class, readonly, nonnull) NSString *Y_OFFSET            NS_SWIFT_NAME(Y_OFFSET);

@property (class, readonly, nonnull) NSString *ALLOW_OFFSCREEN     NS_SWIFT_NAME(ALLOW_OFFSCREEN);

@property (class, readonly, nonnull) NSString *FORCE_ORIENTATION   NS_SWIFT_NAME(FORCE_ORIENTATION);

@end


//MARK: MRAID Values
@interface OXMMRAIDValues : NSObject

@property (class, readonly, nonnull) NSString *LANDSCAPE           NS_SWIFT_NAME(LANDSCAPE);
@property (class, readonly, nonnull) NSString *PORTRAIT            NS_SWIFT_NAME(PORTRAIT);

@end


// MRAID Close Button Positions
@interface OXMMRAIDCloseButtonPosition : NSObject

@property (class, readonly, nonnull) NSString *BOTTOM_CENTER       NS_SWIFT_NAME(BOTTOM_CENTER);
@property (class, readonly, nonnull) NSString *BOTTOM_LEFT         NS_SWIFT_NAME(BOTTOM_LEFT);
@property (class, readonly, nonnull) NSString *BOTTOM_RIGHT        NS_SWIFT_NAME(BOTTOM_RIGHT);
@property (class, readonly, nonnull) NSString *CENTER              NS_SWIFT_NAME(CENTER);
@property (class, readonly, nonnull) NSString *TOP_CENTER          NS_SWIFT_NAME(TOP_CENTER);
@property (class, readonly, nonnull) NSString *TOP_LEFT            NS_SWIFT_NAME(TOP_LEFT);
@property (class, readonly, nonnull) NSString *TOP_RIGHT           NS_SWIFT_NAME(TOP_RIGHT);

@end


// MRAID Close Button Size
@interface OXMMRAIDCloseButtonSize : NSObject

@property (class, readonly) float WIDTH                             NS_SWIFT_NAME(WIDTH);
@property (class, readonly) float HEIGHT                            NS_SWIFT_NAME(HEIGHT);

@end

NS_SWIFT_NAME(MRAIDExpandProperties)
@interface OXMMRAIDExpandProperties : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

- (nonnull instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;

@end

NS_SWIFT_NAME(MRAIDResizeProperties)
@interface OXMMRAIDResizeProperties : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger offsetX;
@property (nonatomic, assign) NSInteger offsetY;
@property (nonatomic, assign) BOOL allowOffscreen;

- (nonnull instancetype)initWithWidth:(NSInteger)width
                               height:(NSInteger)height
                              offsetX:(NSInteger)offsetX
                              offsetY:(NSInteger)offsetY
                       allowOffscreen:(BOOL)allowOffscreen;

@end

//MARK: OXMMRAIDConstants
@interface OXMMRAIDConstants : NSObject

@property (class, readonly, nonnull) NSString *mraidURLScheme;
@property (class, readonly, nonnull) NSArray <NSString *> *allCases;

@end
