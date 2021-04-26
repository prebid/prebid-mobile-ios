//
//  PBMBidResponse.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMBid.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidResponse : NSObject

@property (nonatomic, readonly, nullable) NSArray<PBMBid *> *allBids;
@property (nonatomic, readonly, nullable) PBMBid *winningBid;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *targetingInfo;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
