//
//  OXANativeAsset+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAsset.h"
#import "OXAJsonCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAsset() <OXAJsonCodable>

@property (nonatomic, strong, nullable, readwrite) NSNumber *assetID;

@end

NS_ASSUME_NONNULL_END
