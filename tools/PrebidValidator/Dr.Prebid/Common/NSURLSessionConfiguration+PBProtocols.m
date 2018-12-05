//
//  NSURLSessionConfiguration+PBProtocols.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 12/5/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLSessionConfiguration+PBProtocols.h"
#import "AdServerValidationURLProtocol.h"
#import "SDKValidationURLProtocol.h"

@import ObjectiveC.runtime;

@implementation NSURLSessionConfiguration (PBProtocols)

+ (NSURLSessionConfiguration *)zw_defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [self zw_defaultSessionConfiguration];
    NSArray *protocolClasses = @[[AdServerValidationURLProtocol class], [SDKValidationURLProtocol class]];
    configuration.protocolClasses = protocolClasses;
    return configuration;
}
+ (void)load{
    Method systemMethod = class_getClassMethod([NSURLSessionConfiguration class], @selector(defaultSessionConfiguration));
    Method zwMethod = class_getClassMethod([self class], @selector(zw_defaultSessionConfiguration));
    method_exchangeImplementations(systemMethod, zwMethod);
}

@end
