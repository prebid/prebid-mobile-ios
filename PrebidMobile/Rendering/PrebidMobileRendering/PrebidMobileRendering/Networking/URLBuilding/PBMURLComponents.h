//
//  PBMURLComponents.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface PBMURLComponents : NSObject

@property (nonatomic, copy, readonly) NSString *fullURL;
@property (nonatomic, copy, readonly) NSString *urlString;
@property (nonatomic, copy, readonly) NSString *argumentsString;

- (nullable instancetype)initWithUrl:(NSString *)url paramsDict:(NSDictionary<NSString *, NSString *> *)paramsDict;

@end
NS_ASSUME_NONNULL_END
