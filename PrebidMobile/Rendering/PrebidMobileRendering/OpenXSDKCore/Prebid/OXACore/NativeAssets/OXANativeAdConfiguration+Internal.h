//
//  OXANativeAdConfiguration+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdConfiguration.h"
#import "OXANativeMarkupRequestObject.h"

@interface OXANativeAdConfiguration()

@property (nonatomic, copy, nullable, readwrite) NSString *version;

@property (nonatomic, copy, nonnull) OXANativeMarkupRequestObject *markupRequestObject;

@end
