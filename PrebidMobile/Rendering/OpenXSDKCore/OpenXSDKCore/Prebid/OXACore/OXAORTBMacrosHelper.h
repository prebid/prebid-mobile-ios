//
//  OXAORTBMacrosHelper.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBBid.h"
#import "OXAORTBBidExt.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAORTBMacrosHelper : NSObject

@property (nonatomic, strong, nonnull, readonly) NSDictionary<NSString *, NSString *> *macroValues;

// MARK: - Lifecycle
- (instancetype)initWithBid:(OXMORTBBid<OXAORTBBidExt *> *)bid NS_DESIGNATED_INITIALIZER;

// MARK: - API
- (NSString *)replaceMacrosInString:(nullable NSString *)sourceString;

// MARK: - Overrides
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
