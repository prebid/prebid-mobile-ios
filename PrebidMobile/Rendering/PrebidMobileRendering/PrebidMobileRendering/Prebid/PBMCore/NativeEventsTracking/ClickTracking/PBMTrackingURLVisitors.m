//
//  PBMTrackingURLVisitors.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMTrackingURLVisitors.h"

@implementation PBMTrackingURLVisitors

+ (PBMTrackingURLVisitorBlock)connectionAsTrackingURLVisitor:(id<PBMServerConnectionProtocol>)connection {
    return ^(NSArray<NSString *> *trackingUrlStrings) {
        for(NSString *trackingUrlString in trackingUrlStrings) {
            // TODO: Use 'fireAndForget' ?
            // TODO: Use non-zero timeout ?
            [connection get:trackingUrlString timeout:0 callback:^(PBMServerResponse *response){}];
        }
    };
}

@end
