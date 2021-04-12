//
//  OXAWinNotifierFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "OXAWinNotifierBlock.h"

@protocol OXMServerConnectionProtocol;

typedef OXAWinNotifierBlock _Nonnull (^OXAWinNotifierFactoryBlock)(id<OXMServerConnectionProtocol> _Nonnull connection);
