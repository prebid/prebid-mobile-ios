//
//  PBMErrorFamily.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, PBMErrorFamily) {
    kPBMErrorFamily_SetupErrors,
    //kPBMErrorFamily_TransportError,
    kPBMErrorFamily_KnownServerErrors,
    kPBMErrorFamily_UnknownServerErrors,
    kPBMErrorFamily_ResponseProcessingErrors,
    kPBMErrorFamily_IntegrationLayerErrors,
    kPBMErrorFamily_IncompatibleNativeAdMarkupAsset,
    kPBMErrorFamily_SDKMisuseErrors,
};

FOUNDATION_EXPORT NSString * const PrebidRenderingErrorDomain;

FOUNDATION_EXPORT NSInteger pbmErrorCode(PBMErrorFamily errorFamily, NSInteger errorCodeWithinFamily);
