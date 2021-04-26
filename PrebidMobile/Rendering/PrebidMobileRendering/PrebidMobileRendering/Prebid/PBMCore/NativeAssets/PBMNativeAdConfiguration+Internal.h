//
//  PBMNativeAdConfiguration+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdConfiguration.h"
#import "PBMNativeMarkupRequestObject.h"

@interface PBMNativeAdConfiguration()

@property (nonatomic, copy, nullable, readwrite) NSString *version;

@property (nonatomic, copy, nonnull) PBMNativeMarkupRequestObject *markupRequestObject;

@end
