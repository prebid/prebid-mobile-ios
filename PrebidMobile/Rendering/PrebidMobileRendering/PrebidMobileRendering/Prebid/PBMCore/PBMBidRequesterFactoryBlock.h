//
//  PBMBidRequesterFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidRequesterProtocol.h"

@class PBMAdUnitConfig;

typedef id<PBMBidRequesterProtocol> _Nonnull (^PBMBidRequesterFactoryBlock)(PBMAdUnitConfig * _Nonnull adUnitConfig);
