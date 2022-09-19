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

#import "NSString+PBMExtensions.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation NSString(PBMExtensions)

-(BOOL) PBMdoesMatch: (nonnull NSString *)  regex {
    return [self PBMnumberOfMatches: regex];
}

// Return the number matches using a regular expression.
-(int) PBMnumberOfMatches: (NSString*)  strRegex {
    if (!strRegex) {
        return 0;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strRegex
                                                                           options:0 //NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        PBMLogError(@"Error %@ parsing regex: %@", error.description, strRegex);
        return 0;
    }

    return (int)[regex numberOfMatchesInString:self options:0 range:NSMakeRange(0,self.length)];
}


// Returns substring using the "to" string as ending point starting at 0.
-(nullable NSString *) PBMsubstringToString: (nonnull NSString *) to {
    if (!to) {
        return nil;
    }
    
    NSRange end = [self rangeOfString:to];
    if (end.location == NSNotFound)
        return nil;
    
    NSRange range = NSMakeRange(0, end.location);
    NSString *ret = [self substringWithRange:range];
    return ret;
}

// Returns substring using the "from" string as starting point to the end.
-(nullable NSString *) PBMsubstringFromString: (nonnull NSString *) from {
    if (!from) {
        return nil;
    }
    
    NSRange start = [self rangeOfString:from];
    if (start.location == NSNotFound)
        return nil;
    
    if (start.location + start.length < self.length) {
        NSRange range = NSMakeRange(start.location + start.length, self.length-start.length);
        NSString *ret = [self substringWithRange:range];
        return ret;
    }
    
    return @"";
}

// Substring between starting "from" string to the ending "to" string
// for example,
//    given: "123XXX456"
//    from: "123"
//    to: "456"
// returns "XXX"
-(nullable NSString *) PBMsubstringFromString:(nonnull NSString *)from toString:(nonnull NSString *) to {
    if (!(to && from)) {
        return nil;
    }
    
    NSRange start = [self rangeOfString:from];
    NSRange end = [self rangeOfString:to];

    if ((start.location == NSNotFound) || end.location == NSNotFound)
        return nil;

    if (start.location+start.length <= end.location) {
        NSRange range = NSMakeRange(start.location+start.length, end.location-start.location-start.length);
        NSString* ret = [self substringWithRange:range];
        return ret;
    }
    return nil;
}

// Replace a given string with another using a regular expression.
-(nonnull NSString *) PBMstringByReplacingRegex:(nonnull NSString *) strRegex replaceWith:(nonnull NSString *) replaceWithString {
    if (!(strRegex && replaceWithString)) {
        return self;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strRegex
                                                                           options:0
                                                                             error:&error];
    if (error) {
        PBMLogError(@"Error %@ parsing regex: %@", error.description, strRegex);
        return self;
    }

    NSString *ret = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0,self.length) withTemplate:replaceWithString ];
    if (ret)
        return ret;
    
    return self;
}

// Replace a string given staring and ending postions with another string.
-(nullable NSString *) PBMsubstringFromIndex:(int) fromIndex toIndex:(int) toIndex {
    if ((fromIndex < 0) || (toIndex < 0))
        return nil;
    if (toIndex > self.length)
        return nil;
    if (fromIndex > toIndex)
        return nil;

    NSRange range = NSMakeRange(fromIndex, toIndex-fromIndex);
    NSString *ret = [self substringWithRange:range];
    return ret;
}
@end
