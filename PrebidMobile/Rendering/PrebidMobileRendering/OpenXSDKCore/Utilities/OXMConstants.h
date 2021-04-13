//
//  OXMConstants.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXAPublicConstants.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString *, id> OXMJsonDictionary;
typedef NSMutableDictionary<NSString *, id> OXMMutableJsonDictionary;

typedef NSDictionary<NSString *, NSString *> OXMStringDictionary;
typedef NSMutableDictionary<NSString *, NSString *> OXMMutableStringDictionary;

FOUNDATION_EXPORT NSString * const OXM_DOMAIN_KEY;
FOUNDATION_EXPORT NSString * const OXM_TRANSACTION_STATE_KEY;
FOUNDATION_EXPORT NSString * const OXM_TRACKING_URL_TEMPLATE;
FOUNDATION_EXPORT NSString * const OXM_ORIGINAL_ADUNIT_KEY;
FOUNDATION_EXPORT NSString * const OXM_MOPUB_INITIALIZATION_OPTIONS_KEY;
FOUNDATION_EXPORT NSString * const OXM_PRECACHE_CONFIGURATION_KEY;

typedef NS_ENUM(NSInteger, OXALocationSourceValues) {
    OXALocationSourceValuesGPS NS_SWIFT_NAME(GPS) = 1,                              //From Location Service
    OXALocationSourceValuesIPAddress NS_SWIFT_NAME(IPAddress) = 2,                  //Unused by SDK
    OXALocationSourceValuesUserRegistration NS_SWIFT_NAME(UserRegistration) = 3     //Supplied by Publisher
};

//MARK: Accessibility
@interface OXMAccesibility : NSObject

//Main close button that appears on Interstitials & Clickthrough Browsers
@property (class, readonly) NSString *CloseButtonIdentifier;
@property (class, readonly) NSString *CloseButtonLabel;

//Secondary close button that only appears on the bottom bar of Clickthrough Browsers
@property (class, readonly) NSString *CloseButtonClickThroughBrowserIdentifier;
@property (class, readonly) NSString *CloseButtonClickThroughBrowserLabel;

@property (class, readonly) NSString *WebViewLabel;

@property (class, readonly) NSString *VideoAdView;

@end

//MARK: MRAID
typedef NSString * OXMMRAIDState NS_TYPED_ENUM;
FOUNDATION_EXPORT OXMMRAIDState const OXMMRAIDStateNotEnabled;
FOUNDATION_EXPORT OXMMRAIDState const OXMMRAIDStateDefault;
FOUNDATION_EXPORT OXMMRAIDState const OXMMRAIDStateExpanded;
FOUNDATION_EXPORT OXMMRAIDState const OXMMRAIDStateHidden;
FOUNDATION_EXPORT OXMMRAIDState const OXMMRAIDStateLoading;
FOUNDATION_EXPORT OXMMRAIDState const OXMMRAIDStateResized;


//MARK: Tracking Supression Detection Strings
typedef NSString * OXMTrackingPattern NS_TYPED_ENUM;
FOUNDATION_EXPORT OXMTrackingPattern const OXMTrackingPatternRI;
FOUNDATION_EXPORT OXMTrackingPattern const OXMTrackingPatternRC;
FOUNDATION_EXPORT OXMTrackingPattern const OXMTrackingPatternRDF;
FOUNDATION_EXPORT OXMTrackingPattern const OXMTrackingPatternRR;
FOUNDATION_EXPORT OXMTrackingPattern const OXMTrackingPatternBO;


//MARK: Query String Parameters
typedef NSString * OXMParameterKeys NS_TYPED_ENUM;
FOUNDATION_EXPORT OXMParameterKeys const OXMParameterKeysAPP_STORE_URL;
FOUNDATION_EXPORT OXMParameterKeys const OXMParameterKeysOPEN_RTB;

//MARK: OXMLocationParamKeys
NS_SWIFT_NAME(LocationParamKeys)
@interface OXMLocationParamKeys : NSObject

@property (class, readonly) NSString *Latitude                          NS_SWIFT_NAME(Latitude);
@property (class, readonly) NSString *Longitude                         NS_SWIFT_NAME(Longitude);
@property (class, readonly) NSString *Country                           NS_SWIFT_NAME(Country);
@property (class, readonly) NSString *City                              NS_SWIFT_NAME(City);
@property (class, readonly) NSString *State                             NS_SWIFT_NAME(State);
@property (class, readonly) NSString *Zip                               NS_SWIFT_NAME(Zip);
@property (class, readonly) NSString *LocationSource                    NS_SWIFT_NAME(LocationSource);

@end


//MARK: JSON Parse Keys
//TODO: Change Name
NS_SWIFT_NAME(ParseKey)
@interface OXMParseKey : NSObject

@property (class, readonly) NSString *ADUNIT                            NS_SWIFT_NAME(ADUNIT);
@property (class, readonly) NSString *HEIGHT                            NS_SWIFT_NAME(HEIGHT);
@property (class, readonly) NSString *WIDTH                             NS_SWIFT_NAME(WIDTH);
@property (class, readonly) NSString *HTML                              NS_SWIFT_NAME(HTML);
@property (class, readonly) NSString *IMAGE                             NS_SWIFT_NAME(IMAGE);
@property (class, readonly) NSString *NETWORK_UID                       NS_SWIFT_NAME(NETWORK_UID);
@property (class, readonly) NSString *REVENUE                           NS_SWIFT_NAME(REVENUE);
@property (class, readonly) NSString *SSM_TYPE                          NS_SWIFT_NAME(SSM_TYPE);

@end


//MARK: OXMAutoRefresh
@interface OXMAutoRefresh : NSObject

@property (class, readonly) NSTimeInterval AUTO_REFRESH_DELAY_DEFAULT   NS_SWIFT_NAME(AUTO_REFRESH_DELAY_DEFAULT);
@property (class, readonly) NSTimeInterval AUTO_REFRESH_DELAY_MIN       NS_SWIFT_NAME(AUTO_REFRESH_DELAY_MIN);
@property (class, readonly) NSTimeInterval AUTO_REFRESH_DELAY_MAX       NS_SWIFT_NAME(AUTO_REFRESH_DELAY_MAX);

@end


//MARK: Other Time Intervals
@interface OXMTimeInterval : NSObject

@property (class, readonly) NSTimeInterval VAST_LOADER_TIMEOUT          NS_SWIFT_NAME(VAST_LOADER_TIMEOUT);
@property (class, readonly) NSTimeInterval AD_CLICKED_ALLOWED_INTERVAL  NS_SWIFT_NAME(AD_CLICKED_ALLOWED_INTERVAL);
@property (class, readonly) NSTimeInterval CONNECTION_TIMEOUT_DEFAULT   NS_SWIFT_NAME(CONNECTION_TIMEOUT_DEFAULT);
@property (class, readonly) NSTimeInterval CLOSE_DELAY_MIN              NS_SWIFT_NAME(CLOSE_DELAY_MIN);
@property (class, readonly) NSTimeInterval CLOSE_DELAY_MAX              NS_SWIFT_NAME(CLOSE_DELAY_MAX);
@property (class, readonly) NSTimeInterval FIRE_AND_FORGET_TIMEOUT      NS_SWIFT_NAME(FIRE_AND_FORGET_TIMEOUT);

@end


//TODO: Move to Video
@interface OXMTimeScale : NSObject

@property (class, readonly) NSInteger VIDEO_TIMESCALE                   NS_SWIFT_NAME(VIDEO_TIMESCALE);

@end


//MARK: OXMGeoLocationConstants
NS_SWIFT_NAME(GeoLocationConstants)
@interface OXMGeoLocationConstants : NSObject

@property (class, readonly) double DISTANCE_FILTER                      NS_SWIFT_NAME(DISTANCE_FILTER);

@end


//MARK: OXMConstants
@interface OXMConstants : NSObject

@property (class, readonly) NSArray <NSString *> *supportedVideoMimeTypes           NS_SWIFT_NAME(supportedVideoMimeTypes);
@property (class, readonly) NSArray <NSString *> *urlSchemesForAppStoreAndITunes    NS_SWIFT_NAME(urlSchemesForAppStoreAndITunes);
@property (class, readonly) NSArray <NSString *> *urlSchemesNotSupportedOnSimulator NS_SWIFT_NAME(urlSchemesNotSupportedOnSimulator);
@property (class, readonly) NSArray <NSString *> *urlSchemesNotSupportedOnClickthroughBrowser NS_SWIFT_NAME(urlSchemesNotSupportedOnClickthroughBrowser);

@end

NS_ASSUME_NONNULL_END
