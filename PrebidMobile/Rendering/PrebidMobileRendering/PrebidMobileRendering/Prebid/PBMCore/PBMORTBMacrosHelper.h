//
//  PBMORTBMacrosHelper.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBid.h"
#import "PBMORTBBidExt.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBMacrosHelper : NSObject

@property (nonatomic, strong, nonnull, readonly) NSDictionary<NSString *, NSString *> *macroValues;

// MARK: - Lifecycle
- (instancetype)initWithBid:(PBMORTBBid<PBMORTBBidExt *> *)bid NS_DESIGNATED_INITIALIZER;

// MARK: - API
- (nullable NSString *)replaceMacrosInString:(nullable NSString *)sourceString;

// MARK: - Overrides
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
