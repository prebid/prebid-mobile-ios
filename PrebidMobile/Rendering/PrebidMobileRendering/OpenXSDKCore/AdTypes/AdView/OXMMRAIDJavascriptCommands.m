//
//  OXMMRAIDJavascriptCommands.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMMRAIDJavascriptCommands.h"
#import "OXMFunctions+Private.h"

#import "OXMViewExposure.h"
#import "OXMLog.h"

#pragma mark - Constants

static NSString * const OXMMRAIDCommandFormatSize = @"%@:%@";

#pragma mark - Private Extension

@interface OXMMRAIDJavascriptCommands ()

@property (class, readonly) NSNumberFormatter* floatFormatter;

@end

#pragma mark - Implementation

@implementation OXMMRAIDJavascriptCommands

#pragma mark - command functions

+ (nonnull NSString *)isEnabled {
    return @"typeof mraid !== 'undefined'";
}

+ (nonnull NSString *)nativeCallComplete {
    return [NSString stringWithFormat:@"mraid.nativeCallComplete();"];
}

#pragma mark - SDK state change functions

+ (nonnull NSString *)onReady {
    return @"mraid.onReady();";
}

+ (nonnull NSString *)onReadyExpanded {
    return @"mraid.onReadyExpanded();";
}

+ (nonnull NSString *)onViewableChange:(BOOL)isViewable {
    NSString *strIsViewable = isViewable ? @"true" : @"false";
    return [NSString stringWithFormat:@"mraid.onViewableChange(%@);", strIsViewable];
}

+ (NSString *)onExposureChange:(OXMViewExposure *)viewExposure {
    return [NSString stringWithFormat:@"mraid.onExposureChange(\"%@\");", [viewExposure serializeWithFormatter:[OXMMRAIDJavascriptCommands floatFormatter]]];
}

+ (nonnull NSString *)onSizeChange:(CGSize)newSize {
    return [NSString stringWithFormat:@"mraid.onSizeChange(%@,%@);", [OXMMRAIDJavascriptCommands formatFloat:newSize.width], [OXMMRAIDJavascriptCommands formatFloat:newSize.height]];
}

+ (nonnull NSString *)onStateChange:(nonnull OXMMRAIDState)newState {
    return [NSString stringWithFormat:@"mraid.onStateChange('%@');",newState];
}

+ (nonnull NSString *)onAudioVolumeChange:(NSNumber *)volumePercentage {
    return [NSString stringWithFormat:@"mraid.onAudioVolumeChange(%@);",
            volumePercentage == nil ? @"null" : [OXMMRAIDJavascriptCommands formatFloat:volumePercentage.floatValue]];
}

#pragma mark - update Ad data

+ (nonnull NSString *)updateSupportedFeatures {
    NSString *features = [OXMMRAIDJavascriptCommands getSupportedFeatureString];
    return [NSString stringWithFormat:@"mraid.allSupports = %@;", features];
}

+ (nonnull NSString *)updatePlacementType:(OXMMRAIDPlacementType)type {
    return [NSString stringWithFormat:@"mraid.placementType = '%@';", type];
}

+ (nonnull NSString *)updateMaxSize:(CGSize)newMaxSize {
    return [NSString stringWithFormat:@"mraid.setMaxSize(%@,%@);", [OXMMRAIDJavascriptCommands formatFloat:newMaxSize.width], [OXMMRAIDJavascriptCommands formatFloat:newMaxSize.height]];
}

+ (nonnull NSString *)updateCurrentAppOrientation:(NSString *)orientation locked:(BOOL)locked{
    return [NSString stringWithFormat:@"mraid.setCurrentAppOrientation('%@', %@);",
            orientation, locked ? @"true" : @"false"];
}

+ (nonnull NSString *)updateScreenSize:(CGSize)newScreenSize {
    NSString * width = [NSString stringWithFormat:OXMMRAIDCommandFormatSize, OXMMRAIDParseKeys.WIDTH, [OXMMRAIDJavascriptCommands formatFloat:newScreenSize.width]];
    NSString * height = [NSString stringWithFormat:OXMMRAIDCommandFormatSize, OXMMRAIDParseKeys.HEIGHT, [OXMMRAIDJavascriptCommands formatFloat:newScreenSize.height]];

    return [NSString stringWithFormat:@"mraid.screenSize = {%@,%@};", width, height];
}

+ (nonnull NSString *)updateDefaultPosition:(CGRect)position {
    NSString *strPosition = [OXMMRAIDJavascriptCommands getRectString:position];
    return [NSString stringWithFormat:@"mraid.defaultPosition = %@;", strPosition];
}

+ (nonnull NSString *)updateCurrentPosition:(CGRect)position {
    NSString *strPosition = [OXMMRAIDJavascriptCommands getRectString:position];
    return [NSString stringWithFormat:@"mraid.currentPosition = %@;", strPosition];
}

+ (nonnull NSString *)updateLocation:(CLLocationCoordinate2D)coordinate accuracy:(CLLocationAccuracy)accuracy  timeStamp:(NSTimeInterval)timeStamp {
    return [NSString stringWithFormat:@"mraid.setLocation(%@,%@,%@,%@);",
                [OXMMRAIDJavascriptCommands formatFloat:coordinate.latitude],
                [OXMMRAIDJavascriptCommands formatFloat:coordinate.longitude],
                [OXMMRAIDJavascriptCommands formatFloat:accuracy],
                [OXMMRAIDJavascriptCommands formatFloat:timeStamp]
            ];
}

#pragma mark - get data from Ad

+ (nonnull NSString *)getCurrentPosition {
    return @"JSON.stringify(mraid.getCurrentPosition());";
}

+ (nonnull NSString *)getOrientationProperties {
    return @"JSON.stringify(mraid.getOrientationProperties());";
}

+ (nonnull NSString *)getExpandProperties {
    return @"JSON.stringify(mraid.getExpandProperties());";
}
+ (nonnull NSString *)getResizeProperties {
    return @"JSON.stringify(mraid.getResizeProperties());";
}

#pragma mark - error

+ (nonnull NSString *)onErrorWithMessage:(nonnull NSString *)message action:(nonnull OXMMRAIDAction)action {
    return [NSString stringWithFormat:@"mraid.onError('%@','%@');", message, action];
}

#pragma mark - Internal methods

+ (NSString *)getSupportedFeatureString {
    
    NSDictionary<OXMMRAIDFeature, NSNumber*> *supports = @{
        OXMMRAIDFeatureSMS          : @(YES),
        OXMMRAIDFeaturePhone        : @(YES),
        OXMMRAIDFeatureCalendar     : @(YES),
        OXMMRAIDFeatureSavePicture  : @(YES),
        OXMMRAIDFeatureInlineVideo  : @(YES),
        OXMMRAIDFeatureLocation     : @(YES),
        OXMMRAIDFeatureVPAID        : @(NO),
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:supports options:0 error:nil];
    if (!data) {
        OXMLogError(@"Could not generate support string");
        return @"";
    }
    
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSString *)getRectString:(CGRect)position {
    NSString *x = [NSString stringWithFormat:OXMMRAIDCommandFormatSize, OXMMRAIDParseKeys.X, [OXMMRAIDJavascriptCommands formatFloat:position.origin.x]];
    NSString *y = [NSString stringWithFormat:OXMMRAIDCommandFormatSize, OXMMRAIDParseKeys.Y, [OXMMRAIDJavascriptCommands formatFloat:position.origin.y]];
    NSString *width = [NSString stringWithFormat:OXMMRAIDCommandFormatSize, OXMMRAIDParseKeys.WIDTH, [OXMMRAIDJavascriptCommands formatFloat:position.size.width]];
    NSString *height = [NSString stringWithFormat:OXMMRAIDCommandFormatSize, OXMMRAIDParseKeys.HEIGHT, [OXMMRAIDJavascriptCommands formatFloat:position.size.height]];

    return [NSString stringWithFormat:@"{%@, %@, %@, %@}", x, y, width, height];
}

+ (NSNumberFormatter *)floatFormatter {
    static NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterNoStyle;
        formatter.minimumIntegerDigits = 1;
        formatter.minimumFractionDigits = 1;
        formatter.maximumFractionDigits = 4;
        formatter.usesGroupingSeparator = NO;
        formatter.decimalSeparator = @".";
    });
    
    return formatter;
}

+ (NSString *)formatFloat:(CGFloat)value {
    return [OXMMRAIDJavascriptCommands.floatFormatter stringFromNumber:@(value)];
}

@end
