//
//  OXMAbstractCreative+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransaction.h"

@protocol OXMNSThreadProtocol;

@interface OXMAbstractCreative ()

- (void)setupViewWithThread:(nonnull id<OXMNSThreadProtocol>)thread;

@end
