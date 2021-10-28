/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMORTBMacrosHelper.h"

@implementation PBMORTBMacrosHelper

// MARK: - Lifecycle

- (instancetype)initWithBid:(PBMORTBBid<PBMORTBBidExt *> *)bid {
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
