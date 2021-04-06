//
//  OXMORTBParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMORTBParameterBuilder.h"
#import "OXMLog.h"
#import "OXMConstants.h"
#import "OXMORTBBidRequest.h"

@implementation OXMORTBParameterBuilder

+ (NSDictionary<NSString *, NSString *> *)buildOpenRTBFor:(OXMORTBBidRequest *)bidRequest {
    NSMutableDictionary<NSString *, NSString *> *ret = [NSMutableDictionary<NSString *, NSString *> new];
    
    if (!bidRequest) {
        OXMLogError(@"Invalid properties");
        return ret;
    }
    
    NSError *error = nil;
    NSString *json = [bidRequest toJsonStringWithError:&error];
    if (json) {
        ret[OXMParameterKeysOPEN_RTB] = json;
    } else {
        OXMLogError(@"%@", [error localizedDescription]);
    }
    
    return ret;
}

@end
