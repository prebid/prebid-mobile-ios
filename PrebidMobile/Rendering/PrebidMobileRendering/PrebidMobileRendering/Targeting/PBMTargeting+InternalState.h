//
//  PBMTargeting+InternalState.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMTargeting.h"
#import "PBMORTBBidRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMTargeting ()

@property (nonatomic, strong, nonnull, readonly) NSMutableDictionary<NSString *, NSString *> *parameterDictionary;

- (instancetype)initWithParameters:(NSDictionary<NSString *, NSString *> *)parameters
                        coordinate:(nullable NSValue *)coordinate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
