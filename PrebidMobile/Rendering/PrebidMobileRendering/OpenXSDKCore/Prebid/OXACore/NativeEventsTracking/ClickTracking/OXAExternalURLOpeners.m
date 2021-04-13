//
//  OXAExternalURLOpeners.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAExternalURLOpeners.h"

@implementation OXAExternalURLOpeners

+ (OXAExternalURLOpenerBlock)applicationAsExternalUrlOpener:(id<OXMUIApplicationProtocol>)application {
    return ^(NSURL *url, OXAURLOpenResultHandlerBlock completion, OXMVoidBlock _Nullable onClickthroughExitBlock) {
        if (@available(iOS 10.0, *)) {
            [application openURL:url options:@{} completionHandler:completion];
        } else {
            BOOL const result = [application openURL:url];
            if (completion != nil) {
                completion(result);
            }
        }
        if (onClickthroughExitBlock != nil) {
            onClickthroughExitBlock();
        }
    };
}

@end
