//
//  PBMWinNotifier+Private.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMWinNotifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMWinNotifier ()

+ (nullable NSString *)cacheUrlFromTargeting:(NSDictionary<NSString *, NSString *> *)targeting idKey:(NSString *)idKey;

@end

NS_ASSUME_NONNULL_END
