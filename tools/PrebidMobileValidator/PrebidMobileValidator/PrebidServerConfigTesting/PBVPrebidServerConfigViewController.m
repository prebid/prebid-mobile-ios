//
//  PBVPrebidServerConfigViewController.m
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/12/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBVPrebidServerConfigViewController.h"
#import "PBVPBSRequestResponseValidator.h"

@interface PBVPrebidServerConfigViewController()
@end

@implementation PBVPrebidServerConfigViewController
- (instancetype)initWithValidator:(PBVPBSRequestResponseValidator *) validator
{
    self = [super init];
    if (self) {
        
        UIViewController *first = [[UIViewController alloc]init];
        first.title = @"Request";
        first.view.backgroundColor = [UIColor whiteColor];
        UITextView *requestText = [[UITextView alloc] initWithFrame:self.view.frame];
        requestText.textColor = [UIColor blackColor];
        requestText.text = [self prettyJson:validator.request];
        [first.view addSubview:requestText];
        UIViewController *second = [[UIViewController alloc]init];
        second.title = @"Responsse";
        second.view.backgroundColor = [UIColor whiteColor];
        UITextView *responseText = [[UITextView alloc] initWithFrame:self.view.frame];
        responseText.text = [self prettyJson: validator.response];
        [second.view addSubview:responseText];
        NSArray * controllers = [NSArray arrayWithObjects:first, second, nil];
        self.viewControllers = controllers;
        
    }
    return self;
}

- (NSString *) prettyJson: (NSString *) jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&error];
    if (jsonObject == nil) {
        return jsonString;
    } else {
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        NSString *prettyPrintedJson = [NSString stringWithUTF8String:[prettyJsonData bytes]];
        return prettyPrintedJson;
    }
}
@end


