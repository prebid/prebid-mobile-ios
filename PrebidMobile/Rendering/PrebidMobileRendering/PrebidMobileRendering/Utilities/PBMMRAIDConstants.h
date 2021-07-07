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

#import <Foundation/Foundation.h>

//MARK: MRAID Actions
typedef NSString * _Nonnull PBMMRAIDAction NS_TYPED_ENUM;
// Debug
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionLog;
// MRAID 1
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionOpen;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionClose;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionExpand;
// MRAID 2
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionResize;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionStorePicture;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionCreateCalendarEvent;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionPlayVideo;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionOnOrientationPropertiesChanged;
// MRAID 3
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionUnload;
// ---- end MRAID Actions

// mraid enums and structs
typedef NSString * _Nonnull PBMMRAIDPlacementType NS_TYPED_ENUM;
FOUNDATION_EXPORT PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInline;
FOUNDATION_EXPORT PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInterstitial;

typedef NSString * _Nonnull PBMMRAIDFeature NS_TYPED_ENUM;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureSMS;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeaturePhone;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureCalendar;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureSavePicture;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureInlineVideo;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureLocation;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureVPAID;

//MARK: MRAID Parse Keys
@interface PBMMRAIDParseKeys : NSObject

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
@interface PBMMRAIDValues : NSObject

@property (class, readonly, nonnull) NSString *LANDSCAPE           NS_SWIFT_NAME(LANDSCAPE);
@property (class, readonly, nonnull) NSString *PORTRAIT            NS_SWIFT_NAME(PORTRAIT);

@end


// MRAID Close Button Positions
@interface PBMMRAIDCloseButtonPosition : NSObject

@property (class, readonly, nonnull) NSString *BOTTOM_CENTER       NS_SWIFT_NAME(BOTTOM_CENTER);
@property (class, readonly, nonnull) NSString *BOTTOM_LEFT         NS_SWIFT_NAME(BOTTOM_LEFT);
@property (class, readonly, nonnull) NSString *BOTTOM_RIGHT        NS_SWIFT_NAME(BOTTOM_RIGHT);
@property (class, readonly, nonnull) NSString *CENTER              NS_SWIFT_NAME(CENTER);
@property (class, readonly, nonnull) NSString *TOP_CENTER          NS_SWIFT_NAME(TOP_CENTER);
@property (class, readonly, nonnull) NSString *TOP_LEFT            NS_SWIFT_NAME(TOP_LEFT);
@property (class, readonly, nonnull) NSString *TOP_RIGHT           NS_SWIFT_NAME(TOP_RIGHT);

@end


// MRAID Close Button Size
@interface PBMMRAIDCloseButtonSize : NSObject

@property (class, readonly) float WIDTH                             NS_SWIFT_NAME(WIDTH);
@property (class, readonly) float HEIGHT                            NS_SWIFT_NAME(HEIGHT);

@end

NS_SWIFT_NAME(MRAIDExpandProperties)
@interface PBMMRAIDExpandProperties : NSObject

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

- (nonnull instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height;

@end

NS_SWIFT_NAME(MRAIDResizeProperties)
@interface PBMMRAIDResizeProperties : NSObject

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

//MARK: PBMMRAIDConstants
@interface PBMMRAIDConstants : NSObject

@property (class, readonly, nonnull) NSString *mraidURLScheme;
@property (class, readonly, nonnull) NSArray <NSString *> *allCases;

@end
