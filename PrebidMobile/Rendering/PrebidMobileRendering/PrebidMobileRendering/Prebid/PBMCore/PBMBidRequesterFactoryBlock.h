//
//  PBMBidRequesterFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidRequesterProtocol.h"

@class AdUnitConfig;

typedef id<PBMBidRequesterProtocol> _Nonnull (^PBMBidRequesterFactoryBlock)(AdUnitConfig * _Nonnull adUnitConfig);
