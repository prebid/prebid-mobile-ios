//
//  MockServerRuleSlow.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "MockServerRule.h"

//As MockServerRule but the data is spaced out in chunks making it useful for testing slow connections.
//By default, numChunks is 10 and timeBetweenChunks is 1 second, meaning the full download will take ~10 seconds.
@interface MockServerRuleSlow : MockServerRule
    @property int numChunks;
    @property NSTimeInterval timeBetweenChunks;
@end
