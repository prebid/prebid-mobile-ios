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

#import "PBMLogPrivate.h"
#import "PBMNSThreadProtocol.h"

# pragma mark - Implementation


@implementation PBMLog (PBMLogPrivate)

@dynamic loggingQueue;
@dynamic dateFormatter;

@dynamic sdkVersion;
@dynamic logFileURL;
@dynamic SDKName;

#pragma mark - Public

+ (NSString *)logLevelDescription:(PBMLogLevel)logLevel {
    switch (logLevel) {
        case PBMLogLevelInfo    : return @"INFO";
        case PBMLogLevelWarn    : return @"WARNING";
        case PBMLogLevelError   : return @"ERROR";
        default                 : return @"NONE";
            
    }
}

- (void)logInternal:(NSString *)message
           logLevel:(PBMLogLevel)messageLogLevel
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
                       logLevel:(PBMLogLevel)logLevel
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
                       logLevel:(PBMLogLevel)logLevel
                           file:(NSString *)file
                           line:(unsigned int)line
                       function:(NSString *)function
                         thread:(id<PBMNSThreadProtocol>)thread {
   
    NSString *messageLogLevel = [PBMLog logLevelDescription:logLevel];
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
    NSString *sdkVersion = logLevel != PBMLogLevelError ? @"" : [NSString stringWithFormat:@"v%@ ", self.sdkVersion];
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
