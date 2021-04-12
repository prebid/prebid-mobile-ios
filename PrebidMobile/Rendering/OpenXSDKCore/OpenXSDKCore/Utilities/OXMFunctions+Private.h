//
//  OXMFunctions+Private.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OXMFunctions.h"
#import "OXMConstants.h"
#import "OXMUIApplicationProtocol.h"

@interface OXMFunctions ()

#pragma mark - URLs

+ (void) attemptToOpen:(nonnull NSURL*)url;
+ (void) attemptToOpen:(nonnull NSURL*)url oxmUIApplication:(nonnull id<OXMUIApplicationProtocol>)oxmUIApplication;

#pragma mark - Time

+ (NSTimeInterval)clamp:(NSTimeInterval)value
             lowerBound:(NSTimeInterval)lowerBound
             upperBound:(NSTimeInterval)upperBound;

// Used only in tests
+ (NSInteger)clampInt:(NSInteger)value
             lowerBound:(NSInteger)lowerBound
             upperBound:(NSInteger)upperBound;

+ (NSTimeInterval)clampAutoRefresh:(NSTimeInterval)val;
+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval;
+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval startTime:(dispatch_time_t)startTime; // Currently is used in tests only to check the algorithm for porting from Swift to Objective-C

#pragma mark - JSON

+ (nullable OXMJsonDictionary *)dictionaryFromJSONString:(nonnull NSString *)jsonString error:(NSError* _Nullable __autoreleasing * _Nullable)error
    NS_SWIFT_NAME(dictionaryFromJSONString(_:));

+ (nullable OXMJsonDictionary *)dictionaryFromData:(nonnull NSData *)jsonData error:(NSError* _Nullable __autoreleasing * _Nullable)error
    NS_SWIFT_NAME(dictionaryFromData(_:));

+ (nullable NSString *)toStringJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary error:(NSError* _Nullable __autoreleasing * _Nullable)error;

#pragma mark - SDK Info

+ (nonnull NSBundle *)bundleForSDK;

+ (nullable NSString *)infoPlistValueFor:(nonnull NSString *)key
    NS_SWIFT_NAME(infoPlistValue(_:));

#pragma mark - UI

+ (CGFloat)statusBarHeight;
+ (CGFloat)statusBarHeightForApplication:(nonnull id<OXMUIApplicationProtocol>)application
    NS_SWIFT_NAME(statusBarHeight(application:));

#pragma mark - Device Info

// from the OXMDeviceManager
//TODO: move these to OXMDeviceManager
+ (CGSize)deviceScreenSize;
+ (CGSize)deviceMaxSize;
+ (UIEdgeInsets)safeAreaInsets;
+ (BOOL)isSimulator;

@end
