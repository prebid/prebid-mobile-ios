//
//  NativoUtils.h
//  NativoPrebidSDK
//
//  Created by Matthew Murray on 12/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Debouncable)(id _Nullable param);

@interface NativoUtils : NSObject

+ (Debouncable)debounceAction:(void (^)(id param))action withInterval:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
