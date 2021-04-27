//
//  PBMSDKConfiguration.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMLogLevel.h"
#import "PBMHost.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMSDKConfiguration : NSObject

// MARK: - Class properties
@property (nonatomic, strong, class, readonly) PBMSDKConfiguration *singleton;
@property (nonatomic, class, readonly) NSString *sdkVersion;

// MARK: - Bidding properties
@property (nonatomic, assign) PBMPrebidHost prebidServerHost;
@property (nonatomic, copy) NSString *accountID;

@property (nonatomic, assign) NSInteger bidRequestTimeoutMillis;

// MARK: - Ad handling properties

//Controls how long each creative has to load before it is considered a failure.
@property (nonatomic, assign) NSTimeInterval creativeFactoryTimeout;

//If preRenderContent flag is set, controls how long the creative has to completely pre-render before it is considered a failure.
//Useful for video interstitials.
@property (nonatomic, assign) NSTimeInterval creativeFactoryTimeoutPreRenderContent;

//Controls whether to use PrebidMobileRendering's in-app browser or the Safari App for displaying ad clickthrough content.
@property (nonatomic, assign) BOOL useExternalClickthroughBrowser;

//Controls the verbosity of PrebidMobileRendering's internal logger. Options are (from most to least noisy) .info, .warn, .error and .none. Defaults to .info.
@property (nonatomic, assign) PBMLogLevel logLevel;

//If set to true, the output of PrebidMobileRendering's internal logger is written to a text file. This can be helpful for debugging. Defaults to false.
@property (nonatomic, assign) BOOL debugLogFileEnabled;

//If true, the SDK will periodically try to listen for location updates in order to request location-based ads.
@property (nonatomic, assign) BOOL locationUpdatesEnabled;

// MARK: - SDK Initialization

+ (void)initializeSDK;

- (nullable NSString*)setCustomPrebidServerWithUrl:(nonnull NSString *)url error:(NSError* _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(setCustomPrebidServer(url:));

@end

NS_ASSUME_NONNULL_END
