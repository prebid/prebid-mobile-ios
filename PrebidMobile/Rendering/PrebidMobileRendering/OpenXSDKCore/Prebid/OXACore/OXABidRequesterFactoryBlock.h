//
//  OXABidRequesterFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidRequesterProtocol.h"

@class OXAAdUnitConfig;

typedef id<OXABidRequesterProtocol> _Nonnull (^OXABidRequesterFactoryBlock)(OXAAdUnitConfig * _Nonnull adUnitConfig);
