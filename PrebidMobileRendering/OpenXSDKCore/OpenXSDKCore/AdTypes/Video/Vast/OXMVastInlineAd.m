//
//  OXMVastInlineAd.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastInlineAd.h"

@implementation OXMVastInlineAd

- (instancetype)init {
    self = [super init];
    if (self) {
        self.verificationParameters = [OXMVideoVerificationParameters new];
    }
    
    return self;
}

@end
