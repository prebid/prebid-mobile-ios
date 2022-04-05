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
#import "AdServerResponseViewController.h"
#import "PBVSharedConstants.h"
#import "AdServerValidationMockInterstitial.h"
#import "ColorTool.h"
#import "CustomTextView.h"
@import GoogleMobileAds;

@interface AdServerResponseViewController()
@property PBVLineItemsSetupValidator * validator;
@property UIView *adContainer;
@property NSString *adSizeString;
@property NSString *adFormatName;
@property NSString *adServer;
@property CustomTextView *pbmCreativeHTMLContent;

@property NSString *adServerResponseString;
@end

@implementation AdServerResponseViewController
- (instancetype)initWithValidator:(PBVLineItemsSetupValidator *)validator
{
    self = [super init];
    if (self) {
        self.validator = validator;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Creative Display";
    UIScrollView *container = [[UIScrollView alloc]initWithFrame:self.view.frame];
    container.scrollEnabled = YES;
    int totalHeight = 0;
    self.view = container;
    self.view.backgroundColor = [ColorTool prebidGrey];
   
    self.adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    self.adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    self.adServer = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    UILabel *pbmCreativeHTMLTitle = [[UILabel alloc] init];
    pbmCreativeHTMLTitle.frame = CGRectMake(20, 0, self.view.frame.size.width -20, 50);
    if([self.adServer isEqualToString: kDFPString]){
        pbmCreativeHTMLTitle.text = @"Responded Creative HTML";
    }
    [pbmCreativeHTMLTitle setFont:[UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold]];
    [self fetchCreativeContent];
    
    [pbmCreativeHTMLTitle setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:pbmCreativeHTMLTitle];
    self.pbmCreativeHTMLContent = [[CustomTextView alloc] init];
    self.pbmCreativeHTMLContent.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    self.pbmCreativeHTMLContent.frame = CGRectMake(0, 50, self.view.frame.size.width, 250);
    self.pbmCreativeHTMLContent.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    [self.pbmCreativeHTMLContent setFont:[UIFont fontWithName:@"Courier" size:14.0]];
    [self.pbmCreativeHTMLContent setTextColor:[ColorTool prebidCodeSnippetGrey]];
    [self.view addSubview:self.pbmCreativeHTMLContent];
    NSArray *itemArray = @[@"Received Creative", @"Expected Creative"];
    UISegmentedControl *pbmCreativeControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    pbmCreativeControl.selectedSegmentIndex = 0;
    pbmCreativeControl.tintColor = [ColorTool prebidBlue];
    pbmCreativeControl.backgroundColor = [UIColor whiteColor];
    pbmCreativeControl.layer.cornerRadius = 5.0;
    [pbmCreativeControl addTarget:self action:@selector(pbmCreativeSwitch:) forControlEvents:UIControlEventValueChanged];
    pbmCreativeControl.frame = CGRectMake(20, 310, self.view.frame.size.width -40, 35);
    [self.view addSubview:pbmCreativeControl];
    if ([_adFormatName isEqualToString:kBannerString] || [_adFormatName isEqualToString:kNativeString]) {
        NSArray *adSizeArray = [_adSizeString componentsSeparatedByString:@"x"];
        int height = [adSizeArray[1] intValue];
        _adContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, height +100)];
        totalHeight = height + 450;
        [container setContentSize: CGSizeMake( self.view.frame.size.width, 410+height)];
    } else {
        _adContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, 150)];
        totalHeight = 500;
        [container setContentSize: CGSizeMake( self.view.frame.size.width, 500)];
    }
    _adContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_adContainer];
    container.contentSize = CGSizeMake(self.view.frame.size.width, totalHeight);
    container.contentInset = UIEdgeInsetsZero;
    [self attachReceviedCreative];
}

-(void) fetchCreativeContent {
    NSString *responseCreative = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerResponseCreative];
    
    if([responseCreative isEqualToString:@""]){
        [self performSelectorOnMainThread:@selector(prettyJson:) withObject:[self.validator getAdServerResponse] waitUntilDone:YES];
    } else {
        self.adServerResponseString = responseCreative;
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.adServerResponseString isEqualToString:@""])
            NSLog(@"AdServer Response string empty");
        NSLog(@"adServer response string ************** %@", self.adServerResponseString);
        self.pbmCreativeHTMLContent.text = self.adServerResponseString;
    });
    
    
    
}

- (void) pbmCreativeSwitch:(UISegmentedControl *)segment
{
    if (segment.selectedSegmentIndex == 0) {
        [self attachReceviedCreative];
    } else {
        [self attachExpectedCreative];
    }
}

- (void) attachReceviedCreative
{
    for (UIView *child in _adContainer.subviews) {
        [child removeFromSuperview];
    }
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _adContainer.frame.size.width-40, 75)];
    description.text = @"This creative was returned from the Ad Server, and should match the expected creative.";
    description.numberOfLines = 0;
    [_adContainer addSubview:description];
    if ([_adFormatName isEqualToString:kBannerString] || [_adFormatName isEqualToString:kNativeString]) {
        NSArray *adSizeArray = [_adSizeString componentsSeparatedByString:@"x"];
        int width = [adSizeArray[0] intValue];
        int height = [adSizeArray[1] intValue];
        UIView *adView = (UIView *)[_validator getDisplayable];
        adView.frame = CGRectMake((_adContainer.frame.size.width - width)/2, 75,  width, height);
        [_adContainer addSubview:adView];
    } else {
        UIButton *clickToShow = [[UIButton alloc] initWithFrame:CGRectMake((_adContainer.frame.size.width - 320)/2, 75, 320, 50)];
        clickToShow.backgroundColor = [ColorTool prebidOrange];
        clickToShow.layer.cornerRadius = 10;
        clickToShow.clipsToBounds = YES;
        clickToShow.tag = 0;
        [clickToShow addTarget:self action:@selector(showReceivedInterstiail:) forControlEvents:UIControlEventTouchUpInside];
        [clickToShow setTitle:@"Click to show Interstitial" forState:UIControlStateNormal];
        [_adContainer addSubview:clickToShow];
    }

}

- (void) showReceivedInterstiail: (id) sender
{
    UIButton *button = (UIButton *) sender;
    if (button.tag == 0) {
        if ([_validator.getDisplayable isKindOfClass: [GAMInterstitialAd class] ]) {
            GAMInterstitialAd *interstitial  = (GAMInterstitialAd *)[_validator getDisplayable];
            [interstitial presentFromRootViewController:self];
        } 
    } else if (button.tag == 1) {
        AdServerValidationMockInterstitial *mockInterstitial = [[AdServerValidationMockInterstitial alloc] init];
        [self.navigationController pushViewController:mockInterstitial animated:NO];
    }
}
- (void) attachExpectedCreative
{
    for (UIView *child in _adContainer.subviews) {
        [child removeFromSuperview];
    }
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _adContainer.frame.size.width-40, 75)];
    description.text = @"This creative is built into Dr. Prebid for comparison purposes. Your received creative should match this creative.";
    description.numberOfLines = 0;
    [_adContainer addSubview:description];
    if ([_adFormatName isEqualToString:kBannerString] || [_adFormatName isEqualToString:kNativeString]) {
        NSArray *adSizeArray = [_adSizeString componentsSeparatedByString:@"x"];
        int width = [adSizeArray[0] intValue];
        int height = [adSizeArray[1] intValue];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_adContainer.frame.size.width - width)/2, 75,  width, height)];
        imageView.image = [UIImage imageNamed:_adSizeString];
        [_adContainer addSubview:imageView];
    } else {
        UIButton *clickToShow = [[UIButton alloc] initWithFrame:CGRectMake((_adContainer.frame.size.width - 320)/2, 75, 320, 50)];
        clickToShow.backgroundColor = [ColorTool prebidOrange];
        clickToShow.layer.cornerRadius = 10;
        clickToShow.clipsToBounds = YES;
        clickToShow.tag = 1;
        [clickToShow addTarget:self action:@selector(showReceivedInterstiail:) forControlEvents:UIControlEventTouchUpInside];
        [clickToShow setTitle:@"Click to show Interstitial" forState:UIControlStateNormal];
        [_adContainer addSubview:clickToShow];
    }
}

// Helper function
- (void) prettyJson: (NSString *) jsonString
{
    if(jsonString == nil)
        return;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject == nil) {
        self.adServerResponseString = jsonString;
    } else {
            NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            NSString *prettyPrintedJson =[[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding];
            self.adServerResponseString = prettyPrintedJson;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.adServerResponseString forKey:kAdServerResponseCreative];
}


@end
