//
//  PBMHTMLFormatter.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMHTMLFormatter.h"

@implementation PBMHTMLFormatter

+ (NSString *)ensureHTMLHasBodyAndHTMLTags:(NSString *)html {
    
    NSString *newHTML = [html copy];
    
    //Create the regular expression to match <html> tag
    NSError *error = NULL;
    NSString *pattern = @"(<html>)|(</html>)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *bodyText = [regex stringByReplacingMatchesInString:newHTML options:0 range:NSMakeRange(0, [newHTML length]) withTemplate:@""];
    
    //If string has no <body> tag, wrap the string in a body tag.
    bodyText = [PBMHTMLFormatter wrapBodyIfNeeded:bodyText];
    
    //Wrap the string in a html tag.
    bodyText = [PBMHTMLFormatter wrapHTML:bodyText];
    
    return bodyText;
}

+ (NSString *)wrapBodyIfNeeded:(NSString *)html {
    NSRange bodyRange = [[html lowercaseString] rangeOfString:@"<body"];
    if (bodyRange.location == NSNotFound) {
        return [NSString stringWithFormat:@"<body>%@</body>", html];
    }
    return html;
}

+ (NSString *)wrapHTML:(NSString *)html {
    return [NSString stringWithFormat:@"<html>%@</html>", html];
}

@end
