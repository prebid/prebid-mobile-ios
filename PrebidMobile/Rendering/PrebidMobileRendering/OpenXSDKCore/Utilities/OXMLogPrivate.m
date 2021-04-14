//
//  OXMLogPrivate.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMLogPrivate.h"
#import "OXMNSThreadProtocol.h"

# pragma mark - Implementation


@implementation OXMLog (OXMLogPrivate)

@dynamic loggingQueue;
@dynamic dateFormatter;

@dynamic sdkVersion;
@dynamic logFileURL;
@dynamic SDKName;

#pragma mark - Public

+ (NSString *)logLevelDescription:(OXALogLevel)logLevel {
    switch (logLevel) {
        case OXALogLevelInfo    : return @"INFO";
        case OXALogLevelWarn    : return @"WARNING";
        case OXALogLevelError   : return @"ERROR";
        default                 : return @"NONE";
            
    }
}

- (void)logInternal:(NSString *)message
           logLevel:(OXALogLevel)messageLogLevel
               file:(NSString *)file
               line:(unsigned int)line
           function:(NSString *)function {
    
    if (messageLogLevel < self.logLevel) {
        return;
    }
    
    NSString *fullMessage = [self createFullMessage:message logLevel:messageLogLevel file:file line:line function:function];
    
    [self serialWriteToLog:fullMessage];
}

- (void)serialWriteToLog:(NSString *)message {
    dispatch_async(self.loggingQueue, ^{
        NSLog(@"%@", message);
        [self writeToLogFile:message];
    });
}

#pragma mark - Private

- (NSString *)createFullMessage:(NSString *)message
                       logLevel:(OXALogLevel)logLevel
                           file:(NSString *)file
                           line:(unsigned int)line
                       function:(NSString *)function {
    
    return [self createFullMessage:message
                          logLevel:logLevel
                              file:file
                              line:line
                          function:function
                            thread:[NSThread currentThread]];
}

- (NSString *)createFullMessage:(NSString *)message
                       logLevel:(OXALogLevel)logLevel
                           file:(NSString *)file
                           line:(unsigned int)line
                       function:(NSString *)function
                         thread:(id<OXMNSThreadProtocol>)thread {
   
    NSString *messageLogLevel = [OXMLog logLevelDescription:logLevel];
    NSString *formattedDate = [self.dateFormatter stringFromDate:[NSDate new]];
    
    NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject];
    
    NSString *threadName = @"";
    
    if (thread.isMainThread) {
        threadName = @"[MAIN]";
    } else {
        NSString *threadDescr = NSThread.currentThread.description;
        NSString *threadNumberString = @"number = ";
        threadDescr = [threadDescr substringFromIndex:[threadDescr rangeOfString:threadNumberString].location + threadNumberString.length];
        threadDescr = [threadDescr substringToIndex:[threadDescr rangeOfString:@","].location];
        
        threadName = [NSString stringWithFormat:@"[%@]", threadDescr];
    }

    // After porting SDK to Objective-C the Swift client code can't pass #file, #line as default params anymore.
    // So that, such logs will lose these statements.
    // To do not print empty values or 0 we added a separated kind of log message - without undefined info.
    NSString *sdkVersion = logLevel != OXALogLevelError ? @"" : [NSString stringWithFormat:@"v%@ ", self.sdkVersion];
    NSString *msg = fileName ?
        [NSString stringWithFormat: @" %@%@ %@ %@ %@ %@ [Line %u]: %@", sdkVersion, messageLogLevel, threadName, formattedDate, fileName, function, line, message] :
        [NSString stringWithFormat: @" %@%@ %@ %@ %@", sdkVersion, messageLogLevel, threadName, formattedDate, message];
    
    return [self.SDKName stringByAppendingString:msg];
}

- (void)writeToLogFile:(NSString*) message {
    if (!self.logToFile) {
        return;
    }
    
    NSString *messageWithNewline = [message stringByAppendingString:@"\n"];
    NSData *data = [messageWithNewline dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return;
    }
            
    if ([NSFileManager.defaultManager fileExistsAtPath:self.logFileURL.path]) {
        NSError *error;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:self.logFileURL error:&error];
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
        } else {
            NSLog(@"%@ Couldn't write to log file: %@", self.SDKName, error);
        }
    } else {
        [data writeToURL:self.logFileURL atomically:YES];
    }
}

- (NSString*) getLogFileAsString {
    __block NSString* ret;
    dispatch_sync(self.loggingQueue, ^{
        NSError* error;
        ret = [NSString stringWithContentsOfURL:self.logFileURL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"Error getting log file: %@", error);
        }
    });
    
    if (ret == nil) {
        return @"";
    }
    
    return ret;
}

- (void) clearLogFile {
    dispatch_sync(self.loggingQueue, ^{
        [@"" writeToURL:self.logFileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    });
}

@end
