//
//  PBMPrimaryAdRequesterProtocol.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMPrimaryAdRequesterProtocol <NSObject>

/*!
 @abstract PBM SDK calls this method when it has valid bid/s to pass to the ad server.
 @discussion Note that, if the PBM SDK does not have valid bids, `requestAdWithBidResponse:` will be called with a `nil` bid value.
 @param bidResponse bid response object having useful information that can be passed to the ad server SDK
*/
- (void)requestAdWithBidResponse:(nullable BidResponse *)bidResponse;

@end

NS_ASSUME_NONNULL_END
