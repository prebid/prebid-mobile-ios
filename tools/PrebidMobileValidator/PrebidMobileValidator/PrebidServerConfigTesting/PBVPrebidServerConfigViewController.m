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
        UITextView *requestText = [[UITextView alloc] init];
        requestText.text = validator.request;
        [first.view addSubview:requestText];
        UIViewController *second = [[UIViewController alloc]init];
        second.title = @"Responsse";
        second.view.backgroundColor = [UIColor whiteColor];
        UITextView *responseText = [[UITextView alloc] init];
        responseText.text = validator.response;
        [first.view addSubview:responseText];
        NSArray * controllers = [NSArray arrayWithObjects:first, second, nil];
        self.viewControllers = controllers;
        
    }
    return self;
}
@end


