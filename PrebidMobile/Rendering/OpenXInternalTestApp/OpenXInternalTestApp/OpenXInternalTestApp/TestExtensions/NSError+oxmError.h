//
//  NSError+oxmError.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (oxmError)

+ (NSError *)oxmErrorWithDescription:(NSString *)description NS_SWIFT_NAME(oxmError(description:));

@end

NS_ASSUME_NONNULL_END
