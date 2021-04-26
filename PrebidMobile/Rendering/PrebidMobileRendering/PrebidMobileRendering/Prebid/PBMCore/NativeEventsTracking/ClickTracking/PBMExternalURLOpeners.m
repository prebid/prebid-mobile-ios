//
//  PBMExternalURLOpeners.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMExternalURLOpeners.h"

@implementation PBMExternalURLOpeners

+ (PBMExternalURLOpenerBlock)applicationAsExternalUrlOpener:(id<PBMUIApplicationProtocol>)application {
    return ^(NSURL *url, PBMURLOpenResultHandlerBlock completion, PBMVoidBlock _Nullable onClickthroughExitBlock) {
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
