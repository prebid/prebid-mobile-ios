//
//  PBMORTBParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMORTBParameterBuilder.h"
#import "PBMLog.h"
#import "PBMConstants.h"
#import "PBMORTBBidRequest.h"

@implementation PBMORTBParameterBuilder

+ (NSDictionary<NSString *, NSString *> *)buildOpenRTBFor:(PBMORTBBidRequest *)bidRequest {
    NSMutableDictionary<NSString *, NSString *> *ret = [NSMutableDictionary<NSString *, NSString *> new];
    
    if (!bidRequest) {
        PBMLogError(@"Invalid properties");
        return ret;
    }
    
    NSError *error = nil;
    NSString *json = [bidRequest toJsonStringWithError:&error];
    if (json) {
        ret[PBMParameterKeysOPEN_RTB] = json;
    } else {
        PBMLogError(@"%@", [error localizedDescription]);
    }
    
    return ret;
}

@end
