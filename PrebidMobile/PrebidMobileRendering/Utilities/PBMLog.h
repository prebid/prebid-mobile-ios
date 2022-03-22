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
#import "PBMLogLevel.h"

@class Log;

NS_ASSUME_NONNULL_BEGIN
@interface PBMLog : NSObject

@property (nonatomic, assign) PBMLogLevel logLevel;
@property (nonatomic, assign) BOOL logToFile;

@property (class, readonly) PBMLog *shared;

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
