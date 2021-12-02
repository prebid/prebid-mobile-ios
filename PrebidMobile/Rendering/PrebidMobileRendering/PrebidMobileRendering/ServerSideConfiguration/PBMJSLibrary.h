//
//  PBMJSLibrary.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMJSLibrary : NSObject<NSCoding>

@property (strong, nonatomic, nullable) NSURL *downloadURL;
@property (strong, nonatomic, nonnull) NSString *version;
@property (strong, nonatomic, nullable) NSString *contentsString;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
