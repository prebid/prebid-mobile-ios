//
//  PBMLog.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMLogLevel.h"

NS_ASSUME_NONNULL_BEGIN
@interface PBMLog : NSObject

@property (nonatomic, assign) PBMLogLevel logLevel;
@property (nonatomic, assign) BOOL logToFile;

@property (class, readonly) PBMLog *singleton;

+ (void)logObjC:(NSString *)message
       logLevel:(PBMLogLevel)logLevel
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

#define PBMLogWhereAmI() [PBMLog logObjC:@"" logLevel:PBMLogLevelInfo file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
#define PBMLogInfo( s, ... ) [PBMLog logObjC:[NSString stringWithFormat:(s), ##__VA_ARGS__] logLevel:PBMLogLevelInfo file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
#define PBMLogWarn( s, ... ) [PBMLog logObjC:[NSString stringWithFormat:(s), ##__VA_ARGS__] logLevel:PBMLogLevelWarn file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
#define PBMLogError( s, ... ) [PBMLog logObjC:[NSString stringWithFormat:(s), ##__VA_ARGS__] logLevel:PBMLogLevelError file:__FILE__ line:__LINE__ function:__PRETTY_FUNCTION__]
