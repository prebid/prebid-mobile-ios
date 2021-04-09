//
//  OXAORTBMacrosHelper.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBMacrosHelper.h"

@implementation OXAORTBMacrosHelper

// MARK: - Lifecycle

- (instancetype)initWithBid:(OXMORTBBid<OXAORTBBidExt *> *)bid {
    if (!(self = [super init])) {
        return nil;
    }
    _macroValues = @{
        @"AUCTION_PRICE": bid.price.stringValue ?: @"",
    };
    return self;
}

// MARK: - API

- (NSString *)replaceMacrosInString:(nullable NSString *)sourceString {
    if (!sourceString) {
        return nil;
    }
    NSMutableString * const mutatedString = [sourceString mutableCopy];
    for (NSString *key in self.macroValues.allKeys) {
        // replace `${AUCTION_PRICE}`
        NSString * const normalValue = self.macroValues[key];
        [mutatedString replaceOccurrencesOfString:[NSString stringWithFormat:@"${%@}", key]
                                       withString:normalValue
                                          options:kNilOptions
                                            range:NSMakeRange(0, [mutatedString length])];
        // replace `${AUCTION_PRICE:B64}`
        NSData * const normalValueData = [normalValue dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSString * const base64value = [normalValueData base64EncodedStringWithOptions:kNilOptions];
        [mutatedString replaceOccurrencesOfString:[NSString stringWithFormat:@"${%@:B64}", key]
                                       withString:base64value
                                          options:kNilOptions
                                            range:NSMakeRange(0, [mutatedString length])];
    }
    return mutatedString;
}

@end
