//
//  OXMORTBBidRequestExtPrebid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ext.prebid

@interface OXMORTBBidRequestExtPrebid : OXMORTBAbstract

@property (nonatomic, copy, nullable) NSString *storedRequestID;
@property (nonatomic, strong, nullable) NSArray<NSString *> *dataBidders;

@end

NS_ASSUME_NONNULL_END
