//
//  PBMLog.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMFunctions.h"
#import "PBMLog.h"
#import "PBMLogPrivate.h"

# pragma mark - Private Extension

@interface PBMLog ()

//This semaphore assists in serializing writes to the console & log file
//It will allow 1 thread access to those resources at a time.
@property (nonatomic, strong) dispatch_queue_t loggingQueue;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSString * sdkVersion;
@property (nonatomic, copy) NSURL * logFileURL;

@property (nonatomic, copy) NSString *SDKName;

@end

#pragma mark - Implementation

@implementation PBMLog

#pragma mark - Private

- (instancetype)init {
    self = [super init];
    if (self) {
        self.SDKName = @"prebid-mobile-sdk-rendering";
        
        self.loggingQueue = dispatch_queue_create([self.SDKName UTF8String], NULL);
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.dateFormat = @"MM-dd HH:mm:ss:SSSS";
        
        self.logToFile = NO;
        self.logLevel = PBMLogLevelInfo;
        
        self.sdkVersion = [PBMFunctions sdkVersion];
        self.logFileURL = [self getURLForDoc: [self.SDKName stringByAppendingString:@".txt"]];
    }
    
    return self;
}

#pragma mark - Public

+ (instancetype)singleton {
    static id singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[[self class] alloc] init];
    });
    
    return singleton;
}

+ (void)logObjC:(NSString *)message
       logLevel:(PBMLogLevel)logLevel
           file:(const char *)file
           line:(unsigned int)line
       function:(const char *)function {
    
    NSString *fileName = file ? [NSString stringWithUTF8String:file] : nil;
    NSString *functionName = function ? [NSString stringWithUTF8String:function] : nil;
    
    [self.singleton logInternal:message
                       logLevel:logLevel
                           file:fileName
                           line:line
                       function:functionName];
}

+ (void)info:(NSString *)message {
    [self info:message file:nil line:0 function:nil];
}

+ (void)warn:(NSString *)message {
    [self warn:message file:nil line:0 function:nil];
}

+ (void)error:(NSString *)message {
    [self error:message file:nil line:0 function:nil];
}

+ (void)message:(NSString *)message {
    [self message:message file:nil line:0 function:nil];
}

+ (void)info:(NSString *)message file:(NSString *)file line:(unsigned int)line function:(NSString *)function {
    [self.singleton logInternal:message logLevel:PBMLogLevelInfo file:file line:line function:function];
}

+ (void)warn:(NSString *)message file:(NSString *)file line:(unsigned int)line function:(NSString *)function {
    [self.singleton logInternal:message logLevel:PBMLogLevelWarn file:file line:line function:function];
}

+ (void)error:(NSString *)message file:(NSString *)file line:(unsigned int)line function:(NSString *)function {
    [self.singleton logInternal:message logLevel:PBMLogLevelError file:file line:line function:function];
}

+ (void)message:(NSString *)message file:(NSString *)file line:(unsigned int)line function:(NSString *)function {
    [self.singleton logInternal:message logLevel:PBMLogLevelNone file:file line:line function:function];
}

#pragma mark - Private

- (NSURL *)getURLForDoc:(NSString *)docName {
    if (!docName) {
        return nil;
    }
    
    NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *ret = [temporaryDirectoryURL URLByAppendingPathComponent:docName];
    
    return ret;
}

@end
