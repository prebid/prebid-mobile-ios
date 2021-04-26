//
//  PBMSDKConfiguration.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMSDKConfiguration.h"
#import "PBMSDKConfiguration+InternalState.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMLocationManager.h"
#import "PBMLog.h"
#import "PBMLogPrivate.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMServerConnection.h"
#import "PBMUserConsentDataManager.h"

static NSString * const prodURL = @"https://prebid.openx.net/openrtb2/auction";
static const NSInteger defaultTimeoutMillis = 2000;

static PBMSDKConfiguration *_pbmSdkConfigurationSingleton = nil;


@interface PBMSDKConfiguration()

@property (nonatomic, strong, nullable) NSString *rawServerURL;
@property (nonatomic, strong, nonnull, readonly) NSLock *serverURLLock;

#ifdef DEBUG
//If true, forces viewabilityManager to return positive value.
@property (nonatomic, assign) BOOL forcedIsViewable;
#endif

@end



@implementation PBMSDKConfiguration

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

+ (PBMSDKConfiguration *)singleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pbmSdkConfigurationSingleton = [[PBMSDKConfiguration alloc] init];
    });
    return _pbmSdkConfigurationSingleton;
}

#ifdef DEBUG
+ (void)resetSingleton {
    _pbmSdkConfigurationSingleton = [[PBMSDKConfiguration alloc] init];
}
#endif

+ (NSString *)prodServerURL {
    return prodURL;
}

+ (NSString *)sdkVersion {
    return [PBMFunctions sdkVersion];
}

// MARK: - Ad handling properties (PBM Proxying)

- (void)setLogLevel:(PBMLogLevel)logLevel {
    PBMLog.singleton.logLevel = logLevel;
}

- (PBMLogLevel)logLevel {
    return PBMLog.singleton.logLevel;
}

- (void)setDebugLogFileEnabled:(BOOL)debugLogFileEnabled {
    PBMLog.singleton.logToFile = debugLogFileEnabled;
}

- (BOOL)debugLogFileEnabled {
    return PBMLog.singleton.logToFile;
}

- (void)setLocationUpdatesEnabled:(BOOL)locationUpdatesEnabled {
    [[PBMLocationManager singleton] setLocationUpdatesEnabled:locationUpdatesEnabled];
}

- (BOOL)locationUpdatesEnabled {
    return [[PBMLocationManager singleton] locationUpdatesEnabled];
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
    [PBMServerConnection singleton];
    [PBMLocationManager singleton];
    [PBMUserConsentDataManager singleton];
    [[PBMOpenMeasurementWrapper singleton] initializeJSLibWithBundle:[PBMFunctions bundleForSDK] completion:nil];
    
    NSString *sdkVersion = [PBMFunctions sdkVersion];
    NSString *initializationMessage = [NSString stringWithFormat:@"prebid-mobile-sdk-rendering %@ Initialized", sdkVersion];
    
    [PBMLog.singleton serialWriteToLog:initializationMessage];
}

@end
