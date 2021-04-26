//
//  PBMTargeting+Private.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMTargeting.h"
#import "PBMORTBBidRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMTargeting () <NSCopying, NSLocking>

@property (atomic, strong, nonnull, readonly) NSDictionary<NSString *, NSString *> *parameterDictionaryCopy;
@property (atomic, assign) BOOL disableLockUsage;

@property (atomic, strong, nonnull, readonly) NSArray<NSString *> *accessControlList;
@property (atomic, strong, nonnull, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *userDataDictionary;
@property (atomic, strong, nonnull, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *contextDataDictionary;

@end

NS_ASSUME_NONNULL_END
