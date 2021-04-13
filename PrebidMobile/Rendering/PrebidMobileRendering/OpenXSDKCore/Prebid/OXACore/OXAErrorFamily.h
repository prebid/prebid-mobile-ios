//
//  OXAErrorFamily.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, OXAErrorFamily) {
    kOXAErrorFamily_SetupErrors,
    //kOXAErrorFamily_TransportError,
    kOXAErrorFamily_KnownServerErrors,
    kOXAErrorFamily_UnknownServerErrors,
    kOXAErrorFamily_ResponseProcessingErrors,
    kOXAErrorFamily_IntegrationLayerErrors,
    kOXAErrorFamily_IncompatibleNativeAdMarkupAsset,
    kOXAErrorFamily_SDKMisuseErrors,
};

FOUNDATION_EXPORT NSString * const oxaErrorDomain;

FOUNDATION_EXPORT NSInteger oxaErrorCode(OXAErrorFamily errorFamily, NSInteger errorCodeWithinFamily);
