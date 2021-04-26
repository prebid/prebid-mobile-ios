//
//  PBMWinNotifierFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMWinNotifierBlock.h"

@protocol PBMServerConnectionProtocol;

typedef PBMWinNotifierBlock _Nonnull (^PBMWinNotifierFactoryBlock)(id<PBMServerConnectionProtocol> _Nonnull connection);
