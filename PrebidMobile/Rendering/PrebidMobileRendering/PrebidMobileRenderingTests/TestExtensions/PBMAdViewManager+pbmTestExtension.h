//
//  OXMAdViewManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTransaction.h"
#import "PBMAutoRefreshManager.h"

@interface PBMAdViewManager ()

@property (strong, nullable) id<PBMAdLoadManagerProtocol> adLoadManager;

@property (nonatomic, strong, nullable) PBMTransaction *externalTransaction;
@property (weak, nullable) PBMAbstractCreative *currentCreative;

- (void)setupCreative:(nonnull PBMAbstractCreative *)creative;
- (void)setupCreative:(nonnull PBMAbstractCreative *)creative withThread:(nonnull id<PBMNSThreadProtocol>)thread;


@end
