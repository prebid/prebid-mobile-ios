//
//  OXABidResponse.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXABid.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXABidResponse : NSObject

@property (nonatomic, readonly, nullable) NSArray<OXABid *> *allBids;
@property (nonatomic, readonly, nullable) OXABid *winningBid;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *targetingInfo;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
