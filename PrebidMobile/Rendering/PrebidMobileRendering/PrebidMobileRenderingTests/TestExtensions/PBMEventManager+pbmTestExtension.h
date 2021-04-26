//
//  OXMEventManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTransaction.h"

@interface PBMEventManager ()

@property (nonatomic, strong) NSMutableArray<id<PBMEventTrackerProtocol>> *trackers;

@end
