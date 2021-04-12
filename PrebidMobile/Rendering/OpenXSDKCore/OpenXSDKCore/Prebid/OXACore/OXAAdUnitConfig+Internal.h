//
//  OXAAdUnitConfig+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAAdUnitConfig.h"

#import "OXMAdConfiguration.h"
#import "OXMAdFormat.h"

@interface OXAAdUnitConfig ()

@property (nonatomic, strong, nonnull, readonly) OXMAdConfiguration *adConfiguration;
@property (atomic, strong, nonnull, readonly) NSDictionary<NSString *, NSArray<NSString *> *> *contextDataDictionary;

@end
