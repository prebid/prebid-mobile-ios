//
//  NSString_OxmExt.m
//  AppObjC
//
//  Copyright © 2018 OpenX, Inc. All rights reserved.
//

#import "NSString+OxmExtensions.h"
#import "OXMLog.h"

@implementation NSString(OxmExtensions)

-(BOOL) OXMdoesMatch: (nonnull NSString *)  regex {
    return [self OXMnumberOfMatches: regex];
}

// Return the number matches using a regular expression.
-(int) OXMnumberOfMatches: (NSString*)  strRegex {
    if (!strRegex) {
        return 0;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strRegex
                                                                           options:0 //NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        OXMLogError(@"Error %@ parsing regex: %@", error.description, strRegex);
        return 0;
    }

    return (int)[regex numberOfMatchesInString:self options:0 range:NSMakeRange(0,self.length)];
}


// Returns substring using the "to" string as ending point starting at 0.
-(nullable NSString *) OXMsubstringToString: (nonnull NSString *) to {
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
-(nullable NSString *) OXMsubstringFromString: (nonnull NSString *) from {
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
-(nullable NSString *) OXMsubstringFromString:(nonnull NSString *)from toString:(nonnull NSString *) to {
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
-(nonnull NSString *) OXMstringByReplacingRegex:(nonnull NSString *) strRegex replaceWith:(nonnull NSString *) replaceWithString {
    if (!(strRegex && replaceWithString)) {
        return self;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strRegex
                                                                           options:0
                                                                             error:&error];
    if (error) {
        OXMLogError(@"Error %@ parsing regex: %@", error.description, strRegex);
        return self;
    }

    NSString *ret = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0,self.length) withTemplate:replaceWithString ];
    if (ret)
        return ret;
    
    return self;
}

// Replace a string given staring and ending postions with another string.
-(nullable NSString *) OXMsubstringFromIndex:(int) fromIndex toIndex:(int) toIndex {
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
