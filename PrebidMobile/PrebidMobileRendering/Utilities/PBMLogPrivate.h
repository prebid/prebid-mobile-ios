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

#import "PBMLog.h"

@interface PBMLog (PBMLogPrivate)

@property (nonatomic, strong, nonnull) dispatch_queue_t loggingQueue;
@property (nonatomic, strong, nonnull) NSDateFormatter *dateFormatter;

@property (nonatomic, copy, nonnull) NSString *sdkVersion;
@property (nonatomic, copy, nullable) NSURL *logFileURL;
@property (nonatomic, copy, nonnull) NSString *SDKName;

+ (NSString * _Nonnull)logLevelDescription:(PBMLogLevel)logLevel;

- (void)logInternal:(nullable NSString *)message
           logLevel:(PBMLogLevel)messageLogLevel
               file:(nullable NSString *)file
               line:(unsigned int)line
           function:(nullable NSString *)function;

- (void)serialWriteToLog:(nullable NSString *)message
    NS_SWIFT_NAME(serialWriteToLog(_:));


/**
 Get the contents of the log file.
 Note that this is synchronous on loggingQueue so any write-to-log calls will be resolved in order before this takes place.
 */
- (nonnull NSString*) getLogFileAsString NS_SWIFT_NAME(getLogFileAsString());

/**
 Writes "" to the log file.
 Note that this is synchronous on loggingQueue so any write-to-log calls will be resolved in order before this takes place.
 */
- (void) clearLogFile NS_SWIFT_NAME(clearLogFile());

@end
