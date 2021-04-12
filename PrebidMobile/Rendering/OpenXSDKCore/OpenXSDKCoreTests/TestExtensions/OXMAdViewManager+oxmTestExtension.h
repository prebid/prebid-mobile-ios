//
//  OXMAdViewManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransaction.h"
#import "OXMAutoRefreshManager.h"

@interface OXMAdViewManager ()

@property (strong, nullable) id<OXMAdLoadManagerProtocol> adLoadManager;

@property (nonatomic, strong, nullable) OXMTransaction *externalTransaction;
@property (weak, nullable) OXMAbstractCreative *currentCreative;

- (void)setupCreative:(nonnull OXMAbstractCreative *)creative;
- (void)setupCreative:(nonnull OXMAbstractCreative *)creative withThread:(nonnull id<OXMNSThreadProtocol>)thread;


@end
