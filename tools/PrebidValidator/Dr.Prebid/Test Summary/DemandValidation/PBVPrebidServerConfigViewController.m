/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "PBVPrebidServerConfigViewController.h"
#import "DemandValidator.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PBVPrebidServerConfigViewController() <MFMailComposeViewControllerDelegate, UITextViewDelegate>
@property DemandValidator *validator;
@property UIViewController *first;
@property UIViewController *second;
@property UITextView *requestText;
@property UITextView *responseText;
@end

@implementation PBVPrebidServerConfigViewController
- (instancetype)initWithValidator:(DemandValidator *) validator
{
    self = [super init];
    if (self) {
        _validator = validator;
        NSLog(@"%@", _validator.testResults);
  
        
    }
    return self;
}

// Helper function
- (NSString *) prettyJson: (NSString *) jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject == nil) {
        return jsonString;
    } else {
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        NSString *prettyPrintedJson = [NSString stringWithUTF8String:[prettyJsonData bytes]];
        return prettyPrintedJson;
    }
}



@end


