//
//  OXMLogPrivate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXMLog.h"

@interface OXMLog (OXMLogPrivate)

@property (nonatomic, strong, nonnull) dispatch_queue_t loggingQueue;
@property (nonatomic, strong, nonnull) NSDateFormatter *dateFormatter;

@property (nonatomic, copy, nonnull) NSString *sdkVersion;
@property (nonatomic, copy, nullable) NSURL *logFileURL;
@property (nonatomic, copy, nonnull) NSString *SDKName;

+ (NSString * _Nonnull)logLevelDescription:(OXALogLevel)logLevel;

- (void)logInternal:(nullable NSString *)message
           logLevel:(OXALogLevel)messageLogLevel
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
