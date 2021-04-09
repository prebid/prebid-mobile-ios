//
//  OXASDKConfiguration.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXASDKConfiguration.h"
#import "OXASDKConfiguration+InternalState.h"
#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"
#import "OXMLocationManager.h"
#import "OXMLog.h"
#import "OXMLogPrivate.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMServerConnection.h"
#import "OXMUserConsentDataManager.h"

static NSString * const prodURL = @"https://prebid.openx.net/openrtb2/auction";
static const NSInteger defaultTimeoutMillis = 2000;

static OXASDKConfiguration *_oxaSdkConfigurationSingleton = nil;


@interface OXASDKConfiguration()

@property (nonatomic, strong, nullable) NSString *rawServerURL;
@property (nonatomic, strong, nonnull, readonly) NSLock *serverURLLock;

#ifdef DEBUG
//If true, forces viewabilityManager to return positive value.
@property (nonatomic, assign) BOOL forcedIsViewable;
#endif

@end



@implementation OXASDKConfiguration

NSString *_serverURL = nil;

// MARK: - Lifecycle

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    _creativeFactoryTimeout = 6.0;
    _creativeFactoryTimeoutPreRenderContent = 30.0;
    _useExternalClickthroughBrowser = NO;
    
    _accountID = @"";
    _bidRequestTimeoutMillis = defaultTimeoutMillis;
    _bidRequestTimeoutLock = [[NSLock alloc] init];
    _serverURLLock = [[NSLock alloc] init];
    return self;
}

// MARK: - Class properties

+ (OXASDKConfiguration *)singleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _oxaSdkConfigurationSingleton = [[OXASDKConfiguration alloc] init];
    });
    return _oxaSdkConfigurationSingleton;
}

#ifdef DEBUG
+ (void)resetSingleton {
    _oxaSdkConfigurationSingleton = [[OXASDKConfiguration alloc] init];
}
#endif

+ (NSString *)prodServerURL {
    return prodURL;
}

+ (NSString *)sdkVersion {
    return [OXMFunctions sdkVersion];
}

// MARK: - Ad handling properties (OXM Proxying)

- (void)setLogLevel:(OXALogLevel)logLevel {
    OXMLog.singleton.logLevel = logLevel;
}

- (OXALogLevel)logLevel {
    return OXMLog.singleton.logLevel;
}

- (void)setDebugLogFileEnabled:(BOOL)debugLogFileEnabled {
    OXMLog.singleton.logToFile = debugLogFileEnabled;
}

- (BOOL)debugLogFileEnabled {
    return OXMLog.singleton.logToFile;
}

- (void)setLocationUpdatesEnabled:(BOOL)locationUpdatesEnabled {
    [[OXMLocationManager singleton] setLocationUpdatesEnabled:locationUpdatesEnabled];
}

- (BOOL)locationUpdatesEnabled {
    return [[OXMLocationManager singleton] locationUpdatesEnabled];
}

- (void)setServerURL:(NSString *)serverURL {
    NSString * const newValue = [serverURL copy];
    NSLock * const timeoutLock = self.bidRequestTimeoutLock;
    NSLock * const serverURLLock = self.serverURLLock;
    [serverURLLock lock];
    [timeoutLock lock];
    self.rawServerURL = newValue;
    self.bidRequestTimeoutDynamic = nil;
    [timeoutLock unlock];
    [serverURLLock unlock];
}

- (NSString *)serverURL {
    NSLock * const serverURLLock = self.serverURLLock;
    [serverURLLock lock];
    NSString * const result = self.rawServerURL;
    [serverURLLock unlock];
    return result ?: prodURL;
}

// MARK: - SDK Initialization

+ (void)initializeSDK {
    [OXMServerConnection singleton];
    [OXMLocationManager singleton];
    [OXMUserConsentDataManager singleton];
    [[OXMOpenMeasurementWrapper singleton] initializeJSLibWithBundle:[OXMFunctions bundleForSDK] completion:nil];
    
    NSString *sdkVersion = [OXMFunctions sdkVersion];
    NSString *initializationMessage = [NSString stringWithFormat:@"OpenXSDK %@ Initialized", sdkVersion];
    
    [OXMLog.singleton serialWriteToLog:initializationMessage];
}

@end
