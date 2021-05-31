//
//  PBMWinNotifierBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMAdMarkupStringHandler.h"

@class Bid;

typedef void(^PBMWinNotifierBlock)(Bid * _Nonnull bid, PBMAdMarkupStringHandler _Nonnull adMarkupConsumer);
