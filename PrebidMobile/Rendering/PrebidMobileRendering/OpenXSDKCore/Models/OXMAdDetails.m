//
//  OXMAdDetails.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdDetails.h"

@implementation OXMAdDetails

- (nonnull instancetype)initWithRawResponse:(NSString *)rawResponse
                              transactionId:(NSString *)transactionId {
    self = [super init];
    if (self) {
        self.rawResponse = rawResponse ?: @"";
        self.transactionId = transactionId ?: @"";
    }
    
    return self;
}

@end
