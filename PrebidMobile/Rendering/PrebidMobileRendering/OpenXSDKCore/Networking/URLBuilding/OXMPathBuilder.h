//
//  OXMPathBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OXMPathBuilder : NSObject

+ (NSString *)buildBaseURLForDomain:(NSString *)domain;
+ (NSString *)buildURLPathForDomain:(NSString *)domain path:(NSString *)path;
+ (NSString *)buildACJURLPathForDomain:(NSString *)domain;
+ (NSString *)buildVASTURLPathForDomain:(NSString *)domain;

@end
