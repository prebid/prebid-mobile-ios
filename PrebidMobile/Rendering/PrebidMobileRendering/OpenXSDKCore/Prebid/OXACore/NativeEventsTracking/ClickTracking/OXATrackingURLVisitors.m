//
//  OXATrackingURLVisitors.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXATrackingURLVisitors.h"

@implementation OXATrackingURLVisitors

+ (OXATrackingURLVisitorBlock)connectionAsTrackingURLVisitor:(id<OXMServerConnectionProtocol>)connection {
    return ^(NSArray<NSString *> *trackingUrlStrings) {
        for(NSString *trackingUrlString in trackingUrlStrings) {
            // TODO: Use 'fireAndForget' ?
            // TODO: Use non-zero timeout ?
            [connection get:trackingUrlString timeout:0 callback:^(OXMServerResponse *response){}];
        }
    };
}

@end
