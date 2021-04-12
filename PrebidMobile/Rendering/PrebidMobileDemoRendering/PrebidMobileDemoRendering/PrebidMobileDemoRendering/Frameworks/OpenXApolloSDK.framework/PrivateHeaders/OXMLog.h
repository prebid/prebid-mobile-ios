//
//  OXMLog.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXALogLevel.h"

NS_ASSUME_NONNULL_BEGIN
@interface OXMLog : NSObject

@property (nonatomic, assign) OXALogLevel logLevel;
@property (nonatomic, assign) BOOL logToFile;

@property (class, readonly) OXMLog *singleton;

+ (void)logObjC:(NSString *)message
       logLevel:(OXALogLevel)logLevel
           file:(nullable const char *)file
           line:(unsigned int)line
       function:(nullable const char *)function;

+ (void)info:(NSString *)message;
+ (void)warn:(NSString *)message;
+ (void)error:(NSString *)message;
+ (void)message:(NSString *)message;

+ (void)info:(NSString *)message file:(nullable NSString *)file line:(unsigned int)line function:(nullable NSString *)function;
+ (void)warn:(NSString *)message file:(nullable NSString *)file line:(unsigned int)line function:(nullable NSString *)function;
+ (void)error:(NSString *)message file:(nullable NSString *)file line:(unsigned int)line function:(nullable NSString *)function;
+ (void)message:(NSString *)message file:(nullable NSString *)file line:(unsigned int)line function:(nullable NSString *)function;

@end
NS_ASSUME_NONNULL_END

#define OXMLogWhereAmI() [OXMLog logObjC:@"" logLevel:OXALogLevelInfo file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
#define OXMLogInfo( s, ... ) [OXMLog logObjC:[NSString stringWithFormat:(s), ##__VA_ARGS__] logLevel:OXALogLevelInfo file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
#define OXMLogWarn( s, ... ) [OXMLog logObjC:[NSString stringWithFormat:(s), ##__VA_ARGS__] logLevel:OXALogLevelWarn file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
#define OXMLogError( s, ... ) [OXMLog logObjC:[NSString stringWithFormat:(s), ##__VA_ARGS__] logLevel:OXALogLevelError file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
