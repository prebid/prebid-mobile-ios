//
//  OXMORTBAbstract.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXMORTBAbstract : NSObject <NSCopying>

+ (nullable instancetype)fromJsonString:(NSString *)jsonString error:(NSError* _Nullable __autoreleasing * _Nullable)error
    NS_SWIFT_NAME(from(jsonString:));

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
