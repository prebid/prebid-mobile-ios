//
//  OXAPrimaryAdRequesterProtocol.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXABidResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OXAPrimaryAdRequesterProtocol <NSObject>

/*!
 @abstract OXA SDK calls this method when it has valid bid/s to pass to the ad server.
 @discussion Note that, if the OXA SDK does not have valid bids, `requestAdWithBidResponse:` will be called with a `nil` bid value.
 @param bidResponse bid response object having useful information that can be passed to the ad server SDK
*/
- (void)requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse;

@end

NS_ASSUME_NONNULL_END
