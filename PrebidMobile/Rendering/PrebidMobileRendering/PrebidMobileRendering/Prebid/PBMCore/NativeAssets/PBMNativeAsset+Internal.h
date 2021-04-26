//
//  PBMNativeAsset+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAsset.h"
#import "PBMJsonCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAsset() <PBMJsonCodable>

@property (nonatomic, strong, nullable, readwrite) NSNumber *assetID;

@end

NS_ASSUME_NONNULL_END
