//
//  MPViewabilityManager.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerURLBuilder.h"
#import "MPConstants.h"
#import "MPGlobal.h"
#import "MPHTTPNetworkSession.h"
#import "MPLogging.h"
#import "MPViewabilityManager.h"
#import "OMIDSDK.h"
#import "OMIDScriptInjector.h"

// `NSUserDefaults` entry to the cached Open Measurement Javascript Library.
static NSString * const kCachedOMJSLibraryKey = @"com.mopub.mopub-ios-sdk.viewability.omidjs";

// This is the namespace assigned to us by the IAB and should match the the dashboard.
static NSString * const kOMIDPartnerName = @"mopub";

// Notification Keys
NSString *const kDisableViewabilityTrackerNotification = @"com.mopub.mopub-ios-sdk.viewability.disabletracking";

// Deallocation delay
static NSTimeInterval const kDeallocationDelay = 1; // seconds

@interface MPViewabilityManager()
// State Properties
@property (nonatomic, assign, readwrite) BOOL isEnabled;
@property (nonatomic, assign, readwrite) BOOL isInitialized;

// Open Measurement
@property (class, nonatomic, copy, readonly) NSString *bundledOMIDLibrary;
@property (nonatomic, nullable, strong, readwrite) OMIDMopubPartner *omidPartner;

// Scheduled Deallocation
@property (nonatomic, strong) NSMutableArray<id<MPScheduledDeallocationAdAdapter>> *adaptersScheduledForDeallocation;
@end

@implementation MPViewabilityManager

#pragma mark - Initialization

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static MPViewabilityManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[MPViewabilityManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _isEnabled = YES;
        _isInitialized = NO;
        _omidPartner = nil;
        _adaptersScheduledForDeallocation = [NSMutableArray array];
    }
    
    return self;
}

- (void)initializeWithCompletion:(void(^)(BOOL))complete {
    @synchronized (self) {
        // Already initialization or Viewability has been disabled
        // prior to initialization.
        if (self.isInitialized || !self.isEnabled) {
            complete(self.isInitialized);
            return;
        }
        
        // Attempt to activate the Open Measurement SDK.
        // If it fails to initialize, so does this manager.
        BOOL openMeasurementSdkStarted = [OMIDMopubSDK.sharedInstance activate];
        if (!openMeasurementSdkStarted) {
            complete(self.isInitialized);
            return;
        }
        
        // Initialization is now complete
        self.isInitialized = YES;
        
        MPLogInfo(@"Initialized OM SDK version: %@", OMIDMopubSDK.versionString);
        complete(self.isInitialized);
    }
}

#pragma mark - Disabling Viewability

- (void)disableViewability {
    // Already disabled
    if (!self.isEnabled) {
        return;
    }

    @synchronized (self) {
        self.isEnabled = NO;
        self.omidPartner = nil;
    }
    
    // Log the event before broadcasting in case the notification handlers
    // also have their own logging. This is to preserve log event ordering.
    MPLogEvent([MPLogEvent viewabilityDisabled]);
    
    // Broadcast that Viewability tracking has been disabled.
    [NSNotificationCenter.defaultCenter postNotificationName:kDisableViewabilityTrackerNotification object:nil userInfo:nil];
}

#pragma mark - Open Measurement

+ (NSString * _Nullable)bundledOMIDLibrary {
    NSError *error = nil;
    
    // Attempt to read the contents of the pre-bundled Open Measurement Javascript Library
    NSString *bundledJsFilePath = MPResourcePathForResource(@"omsdk-v1.js");
    NSString *bundledJs = [NSString stringWithContentsOfFile:bundledJsFilePath encoding:NSUTF8StringEncoding error:&error];
    
    NSAssert(bundledJsFilePath != nil, @"Cannot find file omsdk-v1.js in the bundle");
    NSAssert(bundledJs.length > 0, @"The contents of omsdk-v1.js is empty or non-existent");
    
    return bundledJs;
}

/**
 Clears the cached Open Measurement Javascript library.
 @note This use primarily used for unit testing and should not be made public.
 */
- (void)clearCachedOMIDLibrary {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kCachedOMJSLibraryKey];
}

- (NSString * _Nullable)injectViewabilityIntoAdMarkup:(NSString * _Nullable)html {
    // Viewability is not initialized or not enabled, or there is no HTML
    // markup.
    if (!self.isEnabled || !self.isInitialized || html.length == 0) {
        return html;
    }
    
    // Inject the JS service into the ad response that is loaded inside the ad WebView
    NSError *error = nil;
    return [OMIDMopubScriptInjector injectScriptContent:self.omidJsLibrary intoHTML:html error:&error];
}

- (NSString * _Nullable)omidJsLibrary {
    // Retrieve the cached Open Measurement Javascript library.
    NSString *cachedJsLibrary = [NSUserDefaults.standardUserDefaults stringForKey:kCachedOMJSLibraryKey];
    
    // Inject the locally distributed Open Measurement Javascript library
    // into the cache if it doesn't exist in the cache.
    if (cachedJsLibrary == nil) {
        cachedJsLibrary = MPViewabilityManager.bundledOMIDLibrary;
        [NSUserDefaults.standardUserDefaults setObject:cachedJsLibrary forKey:kCachedOMJSLibraryKey];
    }
    
    return cachedJsLibrary;
}

- (OMIDMopubPartner * _Nullable)omidPartner {
    @synchronized (self) {
        // Lazily initialize the backing variable if needed
        if (_omidPartner == nil && self.isEnabled && self.isInitialized) {
            _omidPartner = [[OMIDMopubPartner alloc] initWithName:kOMIDPartnerName versionString:MP_SDK_VERSION];
        }
    } // End synchronized(self)
    
    return _omidPartner;
}

- (NSString *)omidPartnerId {
    return kOMIDPartnerName;
}

- (NSString *)omidVersion {
    return OMIDMopubSDK.versionString;
}

#pragma mark - Scheduled Adapter Deallocation

- (void)scheduleAdapterForDeallocation:(id<MPScheduledDeallocationAdAdapter>)adapter {
    // No adapter to add; should not happen, but here for safety
    if (adapter == nil) {
        return;
    }
    
    // Viewability is not initialized or not enabled.
    if (!self.isEnabled || !self.isInitialized) {
        return;
    }
    
    @synchronized (self) {
        // Automatically end the Viewability tracking session
        [adapter stopViewabilitySession];
        
        // Add the adapter scheduled for deallocation
        [self.adaptersScheduledForDeallocation addObject:adapter];
        
        // Schedule the deallocation
        __weak __typeof__(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDeallocationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf removeAdapterScheduledForDeallocation:adapter];
        });
    }
}

- (void)removeAdapterScheduledForDeallocation:(id<MPScheduledDeallocationAdAdapter>)adapter {
    // No adapter to add; should not happen, but here for safety
    if (adapter == nil) {
        return;
    }
    
    @synchronized (self) {
        // Removing the adapter from the array should trigger deallocation
        // since it's the last strong reference.
        [self.adaptersScheduledForDeallocation removeObject:adapter];
    }
}

@end
