//
//  OXATargeting+InternalState.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXATargeting.h"
#import "OXMORTBBidRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXATargeting ()

@property (nonatomic, strong, nonnull, readonly) NSMutableDictionary<NSString *, NSString *> *parameterDictionary;

- (instancetype)initWithParameters:(NSDictionary<NSString *, NSString *> *)parameters
                        coordinate:(nullable NSValue *)coordinate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
