//
//  AdServerResponseViewController.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 8/24/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdServerResponseViewController.h"
#import "PBVSharedConstants.h"
#import "AdServerValidationMockInterstitial.h"
#import "MPInterstitialAdController.h"
#import "ColorTool.h"
@import GoogleMobileAds;

@interface AdServerResponseViewController()
@property PBVLineItemsSetupValidator * validator;
@property UIView *adContainer;
@property NSString *adSizeString;
@property NSString *adFormatName;
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
    self.view = container;
    self.view.backgroundColor = [ColorTool prebidGrey];
   
    self.adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    self.adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    
    UILabel *pbmCreativeHTMLTitle = [[UILabel alloc] init];
    pbmCreativeHTMLTitle.frame = CGRectMake(20, 0, self.view.frame.size.width -20, 50);
    pbmCreativeHTMLTitle.text = @"Responded Creative HTML";
    [pbmCreativeHTMLTitle setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:pbmCreativeHTMLTitle];
    UITextView *pbmCreativeHTMLContent = [[UITextView alloc] init];
    pbmCreativeHTMLContent.editable = NO;
    pbmCreativeHTMLContent.frame = CGRectMake(0, 50, self.view.frame.size.width, 250);
    pbmCreativeHTMLContent.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    NSString *response = [self.validator getAdServerResponse];
    pbmCreativeHTMLContent.text = response;
    [pbmCreativeHTMLContent setFont:[UIFont systemFontOfSize:14.0]];
    [self.view addSubview:pbmCreativeHTMLContent];
    NSArray *itemArray = @[@"Received Creative", @"Expected Creative"];
    UISegmentedControl *pbmCreativeControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    pbmCreativeControl.selectedSegmentIndex = 0;
    pbmCreativeControl.tintColor = [ColorTool prebidBlue];
    pbmCreativeControl.backgroundColor = [UIColor whiteColor];
    pbmCreativeControl.layer.cornerRadius = 5.0;
    [pbmCreativeControl addTarget:self action:@selector(pbmCreativeSwitch:) forControlEvents:UIControlEventValueChanged];
    pbmCreativeControl.frame = CGRectMake(20, 310, self.view.frame.size.width -40, 35);
    [self.view addSubview:pbmCreativeControl];
    if ([_adFormatName isEqualToString:kBannerString]) {
        NSArray *adSizeArray = [_adSizeString componentsSeparatedByString:@"x"];
        int height = [adSizeArray[1] intValue];
        _adContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, height +80)];
        [container setContentSize: CGSizeMake( self.view.frame.size.width, 410+height)];
    } else {
        _adContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, 150)];
        [container setContentSize: CGSizeMake( self.view.frame.size.width, 500)];
    }
    _adContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_adContainer];
    [self attachReceviedCreative];
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
    if ([_adFormatName isEqualToString:kBannerString]) {
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
        if ([_validator.getDisplayable isKindOfClass: [DFPInterstitial class] ]) {
            DFPInterstitial *interstitial  = (DFPInterstitial *)[_validator getDisplayable];
            [interstitial presentFromRootViewController:self];
        } else if ([_validator.getDisplayable isKindOfClass: [MPInterstitialAdController class]]) {
            MPInterstitialAdController *controller = (MPInterstitialAdController *)_validator.getDisplayable;
            if (controller.ready) {
                [controller showFromViewController:self];
            }
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
    if ([_adFormatName isEqualToString:kBannerString]) {
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

@end
