//
//  OXMWKScriptMessagerLeakAvoider.m
//  OpenXSDKCore
//
//  Created by Yuriy Velichko on 4/4/19.
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMWKScriptMessageHandlerLeakAvoider.h"

@implementation OXMWKScriptMessageHandlerLeakAvoider

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
