//
//  OXMEventManager+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransaction.h"

@interface OXMEventManager ()

@property (nonatomic, strong) NSMutableArray<id<OXMEventTrackerProtocol>> *trackers;

@end
