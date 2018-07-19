//
//  HelpViewController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 7/11/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "HelpViewController.h"
#import <WebKit/WebKit.h>
#import "PBVSharedConstants.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    WKWebView *content = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSString * filePath;
    if ([self.title isEqualToString:kAboutString]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    } else if( [self.title isEqualToString:kGeneralInfoHelpString]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"info-general" ofType:@"html"];
    } else if ( [self.title isEqualToString:kAdServerInfoHelpString]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"info-ad-server" ofType:@"html"];
    } else if ( [self.title isEqualToString:kPrebidServerInfoHelpString]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"info-prebid-server" ofType:@"html"];
    }
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:filePathURL];
    [content loadRequest:request];
    [self.view addSubview:content];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
