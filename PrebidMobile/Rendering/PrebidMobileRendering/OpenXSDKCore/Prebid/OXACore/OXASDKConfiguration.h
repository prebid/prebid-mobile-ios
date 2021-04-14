//
//  OXASDKConfiguration.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXALogLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXASDKConfiguration : NSObject

// MARK: - Class properties
@property (nonatomic, strong, class, readonly) OXASDKConfiguration *singleton;
@property (nonatomic, class, readonly) NSString *sdkVersion;

// MARK: - Bidding properties
@property (nonatomic, copy, readonly) NSString *serverURL;
@property (nonatomic, copy) NSString *accountID;

@property (nonatomic, assign) NSInteger bidRequestTimeoutMillis;

// MARK: - Ad handling properties

//Controls how long each creative has to load before it is considered a failure.
@property (nonatomic, assign) NSTimeInterval creativeFactoryTimeout;

//If preRenderContent flag is set, controls how long the creative has to completely pre-render before it is considered a failure.
//Useful for video interstitials.
@property (nonatomic, assign) NSTimeInterval creativeFactoryTimeoutPreRenderContent;

//Controls whether to use OpenX's in-app browser or the Safari App for displaying ad clickthrough content.
@property (nonatomic, assign) BOOL useExternalClickthroughBrowser;

//Controls the verbosity of OpenXSDKCore's internal logger. Options are (from most to least noisy) .info, .warn, .error and .none. Defaults to .info.
@property (nonatomic, assign) OXALogLevel logLevel;

//If set to true, the output of OpenXSDKCore's internal logger is written to a text file. This can be helpful for debugging. Defaults to false.
@property (nonatomic, assign) BOOL debugLogFileEnabled;

//If true, the SDK will periodically try to listen for location updates in order to request location-based ads.
@property (nonatomic, assign) BOOL locationUpdatesEnabled;

// MARK: - SDK Initialization

+ (void)initializeSDK;

@end

NS_ASSUME_NONNULL_END
