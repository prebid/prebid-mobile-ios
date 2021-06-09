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
