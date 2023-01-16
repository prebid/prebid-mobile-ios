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

#import <UIKit/UIKit.h>
#import "PBMMRAIDJavascriptCommands.h"
#import "PBMFunctions+Private.h"

#import "PBMViewExposure.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Constants

static NSString * const PBMMRAIDCommandFormatSize = @"%@:%@";

#pragma mark - Private Extension

@interface PBMMRAIDJavascriptCommands ()

@property (class, readonly) NSNumberFormatter* floatFormatter;

@end

#pragma mark - Implementation

@implementation PBMMRAIDJavascriptCommands

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

+ (NSString *)onExposureChange:(PBMViewExposure *)viewExposure {
    return [NSString stringWithFormat:@"mraid.onExposureChange(\"%@\");", [viewExposure serializeWithFormatter:[PBMMRAIDJavascriptCommands floatFormatter]]];
}

+ (nonnull NSString *)onSizeChange:(CGSize)newSize {
    return [NSString stringWithFormat:@"mraid.onSizeChange(%@,%@);", [PBMMRAIDJavascriptCommands formatFloat:newSize.width], [PBMMRAIDJavascriptCommands formatFloat:newSize.height]];
}

+ (nonnull NSString *)onStateChange:(nonnull PBMMRAIDState)newState {
    return [NSString stringWithFormat:@"mraid.onStateChange('%@');",newState];
}

+ (nonnull NSString *)onAudioVolumeChange:(NSNumber *)volumePercentage {
    return [NSString stringWithFormat:@"mraid.onAudioVolumeChange(%@);",
            volumePercentage == nil ? @"null" : [PBMMRAIDJavascriptCommands formatFloat:volumePercentage.floatValue]];
}

#pragma mark - update Ad data

+ (nonnull NSString *)updateSupportedFeatures {
    NSString *features = [PBMMRAIDJavascriptCommands getSupportedFeatureString];
    return [NSString stringWithFormat:@"mraid.allSupports = %@;", features];
}

+ (nonnull NSString *)updatePlacementType:(PBMMRAIDPlacementType)type {
    return [NSString stringWithFormat:@"mraid.placementType = '%@';", type];
}

+ (nonnull NSString *)updateMaxSize:(CGSize)newMaxSize {
    return [NSString stringWithFormat:@"mraid.setMaxSize(%@,%@);", [PBMMRAIDJavascriptCommands formatFloat:newMaxSize.width], [PBMMRAIDJavascriptCommands formatFloat:newMaxSize.height]];
}

+ (nonnull NSString *)updateCurrentAppOrientation:(NSString *)orientation locked:(BOOL)locked{
    return [NSString stringWithFormat:@"mraid.setCurrentAppOrientation('%@', %@);",
            orientation, locked ? @"true" : @"false"];
}

+ (nonnull NSString *)updateScreenSize:(CGSize)newScreenSize {
    NSString * width = [NSString stringWithFormat:PBMMRAIDCommandFormatSize, PBMMRAIDParseKeys.WIDTH, [PBMMRAIDJavascriptCommands formatFloat:newScreenSize.width]];
    NSString * height = [NSString stringWithFormat:PBMMRAIDCommandFormatSize, PBMMRAIDParseKeys.HEIGHT, [PBMMRAIDJavascriptCommands formatFloat:newScreenSize.height]];

    return [NSString stringWithFormat:@"mraid.screenSize = {%@,%@};", width, height];
}

+ (nonnull NSString *)updateDefaultPosition:(CGRect)position {
    NSString *strPosition = [PBMMRAIDJavascriptCommands getRectString:position];
    return [NSString stringWithFormat:@"mraid.defaultPosition = %@;", strPosition];
}

+ (nonnull NSString *)updateCurrentPosition:(CGRect)position {
    NSString *strPosition = [PBMMRAIDJavascriptCommands getRectString:position];
    return [NSString stringWithFormat:@"mraid.currentPosition = %@;", strPosition];
}

+ (nonnull NSString *)updateLocation:(CLLocationCoordinate2D)coordinate accuracy:(CLLocationAccuracy)accuracy  timeStamp:(NSTimeInterval)timeStamp {
    return [NSString stringWithFormat:@"mraid.setLocation(%@,%@,%@,%@);",
                [PBMMRAIDJavascriptCommands formatFloat:coordinate.latitude],
                [PBMMRAIDJavascriptCommands formatFloat:coordinate.longitude],
                [PBMMRAIDJavascriptCommands formatFloat:accuracy],
                [PBMMRAIDJavascriptCommands formatFloat:timeStamp]
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

+ (nonnull NSString *)onErrorWithMessage:(nonnull NSString *)message action:(nonnull PBMMRAIDAction)action {
    return [NSString stringWithFormat:@"mraid.onError('%@','%@');", message, action];
}

#pragma mark - Internal methods

+ (NSString *)getSupportedFeatureString {
    
    NSDictionary<PBMMRAIDFeature, NSNumber*> *supports = @{
        PBMMRAIDFeatureSMS          : @(YES),
        PBMMRAIDFeaturePhone        : @(YES),
        PBMMRAIDFeatureCalendar     : @(NO),
        PBMMRAIDFeatureSavePicture  : @(NO),
        PBMMRAIDFeatureInlineVideo  : @(YES),
        PBMMRAIDFeatureLocation     : @(YES),
        PBMMRAIDFeatureVPAID        : @(NO),
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:supports options:0 error:nil];
    if (!data) {
        PBMLogError(@"Could not generate support string");
        return @"";
    }
    
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSString *)getRectString:(CGRect)position {
    NSString *x = [NSString stringWithFormat:PBMMRAIDCommandFormatSize, PBMMRAIDParseKeys.X, [PBMMRAIDJavascriptCommands formatFloat:position.origin.x]];
    NSString *y = [NSString stringWithFormat:PBMMRAIDCommandFormatSize, PBMMRAIDParseKeys.Y, [PBMMRAIDJavascriptCommands formatFloat:position.origin.y]];
    NSString *width = [NSString stringWithFormat:PBMMRAIDCommandFormatSize, PBMMRAIDParseKeys.WIDTH, [PBMMRAIDJavascriptCommands formatFloat:position.size.width]];
    NSString *height = [NSString stringWithFormat:PBMMRAIDCommandFormatSize, PBMMRAIDParseKeys.HEIGHT, [PBMMRAIDJavascriptCommands formatFloat:position.size.height]];

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
    return [PBMMRAIDJavascriptCommands.floatFormatter stringFromNumber:@(value)];
}

@end
