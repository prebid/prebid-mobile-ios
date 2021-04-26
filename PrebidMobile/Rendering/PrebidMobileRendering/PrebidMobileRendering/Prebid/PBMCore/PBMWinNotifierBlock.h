//
//  PBMWinNotifierBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMAdMarkupStringHandler.h"

@class PBMBid;

typedef void(^PBMWinNotifierBlock)(PBMBid * _Nonnull bid, PBMAdMarkupStringHandler _Nonnull adMarkupConsumer);
