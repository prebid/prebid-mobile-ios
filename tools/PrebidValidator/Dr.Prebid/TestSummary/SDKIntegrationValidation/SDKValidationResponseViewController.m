//
//  SDKValidationResponseViewController.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 9/11/18.
//  Copyright © 2018 Prebid. All rights reserved.
//


#import "SDKValidationResponseViewController.h"
#import "ColorTool.h"
#import "PBVSharedConstants.h"
#import "MPInterstitialAdController.h"
@import GoogleMobileAds;

@interface SDKValidationResponseViewController ()
@property PBVPrebidSDKValidator *validator;
@end

@implementation SDKValidationResponseViewController

- (instancetype)initWithValidator:(PBVPrebidSDKValidator *)validator
{
    self = [super init];
    if (self) {
        self.validator = validator;
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"Creative Display";
    UIScrollView *container = [[UIScrollView alloc]initWithFrame:self.view.frame];
    container.scrollEnabled = YES;
    self.view = container;
    self.view.backgroundColor = [ColorTool prebidGrey];
    
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    
    UILabel *pbmCreativeHTMLTitle = [[UILabel alloc] init];
    pbmCreativeHTMLTitle.frame = CGRectMake(20, 0, self.view.frame.size.width -20, 50);
    pbmCreativeHTMLTitle.text = @"Responded Creative HTML";
    [pbmCreativeHTMLTitle setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:pbmCreativeHTMLTitle];
    UITextView *pbmCreativeHTMLContent = [[UITextView alloc] init];
    pbmCreativeHTMLContent.editable = NO;
    pbmCreativeHTMLContent.frame = CGRectMake(0, 50, self.view.frame.size.width, 250);
    NSString *response = [self.validator getAdServerResponse];
    pbmCreativeHTMLContent.text = response;
    [self.view addSubview:pbmCreativeHTMLContent];
    UILabel * receivedCreativeLabel = [[UILabel alloc] init];
    receivedCreativeLabel.text = @"Received Creative";
    receivedCreativeLabel.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 50);
    [receivedCreativeLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:receivedCreativeLabel];
    UIView *adContainer = [[UIView alloc] init];
    adContainer.backgroundColor = [UIColor whiteColor];
    if ([adFormatName isEqualToString:kBannerString]) {
        NSArray *adSizeArray = [adSizeString componentsSeparatedByString:@"x"];
        int width = [adSizeArray[0] intValue];
        int height = [adSizeArray[1] intValue];
        adContainer.frame = CGRectMake(0, 350, self.view.frame.size.width, height + +20);
        UIView *adView = (UIView *)[self.validator getAdObject];
        adView.frame = CGRectMake((adContainer.frame.size.width - width)/2, 10,  width, height);
        [adContainer addSubview:adView];
    } else {
        adContainer.frame = CGRectMake(0, 350, self.view.frame.size.width, 150);
        UIButton *clickToShow = [[UIButton alloc] initWithFrame:CGRectMake((adContainer.frame.size.width - 320)/2, 50, 320, 50)];
        clickToShow.backgroundColor = [ColorTool prebidOrange];
        clickToShow.layer.cornerRadius = 10;
        clickToShow.clipsToBounds = YES;
        clickToShow.tag = 0;
        [clickToShow addTarget:self action:@selector(showReceivedInterstiail:) forControlEvents:UIControlEventTouchUpInside];
        [clickToShow setTitle:@"Click to show Interstitial" forState:UIControlStateNormal];
        [adContainer addSubview:clickToShow];
    }
    [self.view addSubview:adContainer];
}

- (void)showReceivedInterstiail: (id) sender
{
    if ([_validator.getAdObject isKindOfClass: [DFPInterstitial class] ]) {
        DFPInterstitial *interstitial  = (DFPInterstitial *)[_validator getAdObject];
        [interstitial presentFromRootViewController:self];
    } else if ([_validator.getAdObject isKindOfClass: [MPInterstitialAdController class]]) {
        MPInterstitialAdController *controller = (MPInterstitialAdController *)_validator.getAdObject;
        if (controller.ready) {
            [controller showFromViewController:self];
        }
    }
}

@end


