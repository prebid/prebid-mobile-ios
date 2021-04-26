//
//  PBMWKScriptMessageHandlerLeakAvoider.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMWKScriptMessageHandlerLeakAvoider.h"

@implementation PBMWKScriptMessageHandlerLeakAvoider

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
