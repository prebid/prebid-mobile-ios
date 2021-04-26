//
//  PBMMRAIDJavascriptCommands.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@import CoreLocation;

#import <Foundation/Foundation.h>
#import "PBMConstants.h"
#import "PBMMRAIDConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class PBMViewExposure;

@interface PBMMRAIDJavascriptCommands : NSObject

// command functions
+ (NSString *)isEnabled;

// Notifies the ad that the current native call completed
+ (nonnull NSString *)nativeCallComplete;

// SDK state change functions
+ (NSString *)onReady;
+ (NSString *)onReadyExpanded;
+ (NSString *)onViewableChange:(BOOL)isViewable;
+ (NSString *)onExposureChange:(PBMViewExposure *)viewExposure;
+ (NSString *)onSizeChange:(CGSize)newSize;
+ (NSString *)onStateChange:(PBMMRAIDState)newState;
+ (NSString *)onAudioVolumeChange:(nullable NSNumber *)volumePercentage;

// update Ad data
+ (NSString *)updateSupportedFeatures;
+ (NSString *)updatePlacementType:(PBMMRAIDPlacementType)type;
+ (NSString *)updateMaxSize:(CGSize)newMaxSize;
+ (NSString *)updateScreenSize:(CGSize)newScreenSize;
+ (NSString *)updateDefaultPosition:(CGRect)position;
+ (NSString *)updateCurrentPosition:(CGRect)position;
+ (NSString *)updateLocation:(CLLocationCoordinate2D)coordinate accuracy:(CLLocationAccuracy)accuracy timeStamp:(NSTimeInterval)timeStamp;
+ (NSString *)updateCurrentAppOrientation:(NSString *)orientation locked:(BOOL)locked;

// get data from Ad
+ (NSString *)getCurrentPosition;
+ (NSString *)getOrientationProperties;
+ (NSString *)getExpandProperties;
+ (NSString *)getResizeProperties;

// error
+ (NSString *)onErrorWithMessage:(NSString *)message action:(PBMMRAIDAction)action
    NS_SWIFT_NAME(onError(_:action:));

@end

NS_ASSUME_NONNULL_END
