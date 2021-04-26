//
//  OXMAbstractCreative+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTransaction.h"

@protocol PBMNSThreadProtocol;

@interface PBMAbstractCreative ()

- (void)setupViewWithThread:(nonnull id<PBMNSThreadProtocol>)thread;

@end
