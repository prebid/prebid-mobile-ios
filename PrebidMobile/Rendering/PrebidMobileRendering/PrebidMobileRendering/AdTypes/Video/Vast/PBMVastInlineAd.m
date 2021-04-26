//
//  PBMVastInlineAd.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastInlineAd.h"

@implementation PBMVastInlineAd

- (instancetype)init {
    self = [super init];
    if (self) {
        self.verificationParameters = [PBMVideoVerificationParameters new];
    }
    
    return self;
}

@end
