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
    NSMutableString *htmlString = [[NSMutableString alloc] init];
    [htmlString appendString:@"<head>"];
    [htmlString appendString:@"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"];
    // TODO: add style sheet
    [htmlString appendString:@"</head><body>"];
    if ([self.title isEqualToString:kAboutString]) {
        [htmlString appendString:@"Let me tell you what is Dr.Prebid."];
    } else if( [self.title isEqualToString:kGeneralInfoHelpString]) {
        [htmlString appendString:@"Let me tell you what is General Info."];
    } else if ( [self.title isEqualToString:kAdServerInfoHelpString]) {
        [htmlString appendString:@"Let me tell you what is Ad Server Info."];
    } else if ( [self.title isEqualToString:kPrebidServerInfoHelpString]) {
        [htmlString appendString:@"Let me tell you what is Prebid Server Info."];
    }
    [htmlString appendString:@"</body>"];
    [content loadHTMLString:htmlString baseURL:nil];
    [self.view addSubview:content];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
