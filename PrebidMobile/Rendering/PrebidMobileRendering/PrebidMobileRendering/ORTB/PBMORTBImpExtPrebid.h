//
//  PBMORTBImpExtPrebid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBImpExtPrebid : PBMORTBAbstract

@property (nonatomic, copy, nullable) NSString *storedRequestID;
@property (nonatomic, assign) BOOL isRewardedInventory;

@end

NS_ASSUME_NONNULL_END
