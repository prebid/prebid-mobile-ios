//
//  NSError+oxmError.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (pbmError)

+ (NSError *)pbmErrorWithDescription:(NSString *)description NS_SWIFT_NAME(pbmError(description:));

@end

NS_ASSUME_NONNULL_END
