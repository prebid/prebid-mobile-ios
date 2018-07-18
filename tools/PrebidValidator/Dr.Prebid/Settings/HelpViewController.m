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
        [htmlString appendString:@"<h1 align=center>Dr. Prebid</h1>"];
       [htmlString appendString:@"<p align=center>Version: 1.0</p><p>[Do we need any disclaimers or other legal stuff here?]</p><p>Dr. Prebid is here to help you validate and troubleshoot your implementation of Prebid Mobile. You can use this app to ensure your ad server setup, Prebid Server configuration, and Prebid Mobile SDK implementation are all set up correctly and ready for production. You can also use Dr. Prebid to troubleshoot if you’re not receiving the bid responses you’re expecting.</p><p>Simply enter the information about your configuration into the <b>Setup</b> screen and Dr. Prebid will run three tests to validate your configuration:</p><ul><li><strong>Ad Server Setup</strong> <br /> Determines whether your line items are configured correctly on your ad server.</li><li><strong>Prebid Server Configuration</strong> <br /> Validates your Prebid Server setup. This test performs real-time demand validation by creating a request that is sent to Prebid Server.</li><li><strong>Prebid Mobile SDK Validation</strong> <br /> An end-to-end test validating your complete configuration. This test uses your Prebid Mobile implementation to create an ad unit for your selected Ad Server and apply bids.</li></ul></p>For details on the validation tests, see <a href=\"http://prebid.org/prebid-mobile/dr-prebid.html\">Dr. Prebid App</a> on Prebid.org.</p>"];
    } else if( [self.title isEqualToString:kGeneralInfoHelpString]) {
        [htmlString appendString:@" <h1>General</h1><h2>Ad Format</h2><p>The type of ad you want to test.<p><p>Select from:<p><ul><li><i>Banner</i></li><li><i>Interstitial</i></li></ul><h2>Ad Size</h2><p>The size of the ad for the ad slot you’ll be filling. Tap to display a list of sizes you can select from. (<strong>Note:</strong> For Banner ad format only. Not applicable for Interstitial ads.)</p>"];
    } else if ( [self.title isEqualToString:kAdServerInfoHelpString]) {
        [htmlString appendString:@"<h1>Ad Server</h1><h2>Ad Server</h2><p>Your primary ad server.</p><p>Select from:</p><ul><li><i>DFP</i></li><li><i>MoPub</i></li></ul><h2>Ad Unit ID</h2><p>The unique identifier for the relevant ad slot in the primary ad server.<p><p>Type in your ad unit ID, or you can copy/paste via the <b>Scan QR code</b> option. (See \"QR Code Scanning\" in <a href=\"http://prebid.org/prebid-mobile/dr-prebid.html\">Dr. Prebid App</a> for more on using QR codes.)</p><h2>Bid Price</h2><p>Enter the decimal value (such as 0.50) of the USD bid price bucket your line item is targeting.  Note that Dr. Prebid will <em>not</em> round this value using price buckets, so ensure that you have a line item targeting this bid price.</p>"];
    } else if ( [self.title isEqualToString:kPrebidServerInfoHelpString]) {
        [htmlString appendString:@"<h1>Prebid Server</h1><h2>Account ID</h2><p>The account ID you were assigned when you registered with your Prebid Server host.</p><p>Type in your account ID, or you can copy/paste via the <b>Scan QR code</b> option. (See \"QR Code Scanning\" in <a href=\"http://prebid.org/prebid-mobile/dr-prebid.html\">Dr. Prebid App</a> for more on using QR codes.)</p><h2>Config ID</h2><p>The ID of the server-side configuration you defined in Prebid Server for the ad unit you’re testing.</p><p>Type in your config ID, or you can copy/paste via the <b>Scan QR code</b> option. (See \"QR Code Scanning\" in <a href=\"http://prebid.org/prebid-mobile/dr-prebid.html\">Dr. Prebid App</a> for more on using QR codes.)</p><h2>Server Host</h2><p>Select your Prebid Server host:</p> <ul><li><i>AppNexus</i></li><li><i>Rubicon</i></li></ul>"];
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
