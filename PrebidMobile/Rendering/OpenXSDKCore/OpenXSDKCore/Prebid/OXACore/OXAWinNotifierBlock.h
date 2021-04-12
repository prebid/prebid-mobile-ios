//
//  OXAWinNotifierBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "OXAAdMarkupStringHandler.h"

@class OXABid;

typedef void(^OXAWinNotifierBlock)(OXABid * _Nonnull bid, OXAAdMarkupStringHandler _Nonnull adMarkupConsumer);
