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
    if ([self.title isEqualToString:kAboutString]) {
        [content loadHTMLString:@"<body>Let me tell you what is Dr.Prebid</body>" baseURL:nil];
    } else if( [self.title isEqualToString:kGeneralInfoHelpString]) {
        [content loadHTMLString:@"<body>Let me tell you what is General Info.</body>" baseURL:nil];
    } else if ( [self.title isEqualToString:kAdServerInfoHelpString]) {
        [content loadHTMLString:@"<body>Let me tell you what is Ad Server Info.</body>" baseURL:nil];
    } else if ( [self.title isEqualToString:kPrebidServerInfoHelpString]) {
        [content loadHTMLString:@"<body>Let me tell you what is Prebid Server Info.</body>" baseURL:nil];
    }
    [self.view addSubview:content];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
