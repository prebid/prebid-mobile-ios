//
//  NSError+MPAdditions.m
//  MoPubSDK
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "NSError+MPAdditions.h"
#import "MPError.h"

@implementation NSError (MPAdditions)

- (BOOL)isAdRequestTimedOutError {
    return ([self.domain isEqualToString:kMOPUBErrorDomain] && self.code == MOPUBErrorAdRequestTimedOut);
}

@end
