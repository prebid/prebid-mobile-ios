//
//  LineItemsTabController.m
//  PrebidMobileValidator
//
//  Created by Punnaghai Puviarasu on 4/5/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "LineItemsTabController.h"
#import "SettingsViewController.h"
#import "LineItemAdsViewController.h"
#import "LineItemLogViewController.h"
#import <MessageUI/MessageUI.h>

NSString *__nonnull const kTitleText = @"AdServer Setup Validator";

#import "LineItemURLProtocol.h"
#import "PBVSharedConstants.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import "LineItemKeywordsManager.h"

@import GoogleMobileAds;

@interface LineItemsTabController()<MPAdViewDelegate,MPInterstitialAdControllerDelegate,GADBannerViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *keywordsDictionary;

@property (nonatomic, strong) MPInterstitialAdController *interstitial;

@property (nonatomic, strong) DFPBannerView *instantAdView;

@property (nonatomic, strong) NSArray *bidPrices;

@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, assign) BOOL isInterstitial;
@property (nonatomic, assign) BOOL isMoPub;
@property (nonatomic, assign) BOOL isDFP;

@property (nonatomic, assign) CGSize adSize;

@property (nonatomic, strong) NSMutableArray *adViews;

@end

@implementation LineItemsTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = kTitleText;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ScreenGrab" style:UIBarButtonItemStylePlain target:self action:@selector(captureScreen)];
    
//    [NSURLProtocol registerClass:[LineItemURLProtocol class]];
    
    [self createTabs];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(img, nil, nil,nil);
    [self sendEmail];
    //return img;
}

- (void)sendEmail {
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = @"Test Subject!";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@test.com"];
    
    if([MFMessageComposeViewController canSendText]){
    
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
    
        [mc setToRecipients:toRecipents];
    
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) createTabs {
    LineItemAdsViewController *lineItemsAdController = [[LineItemAdsViewController alloc] init];
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"Ads" image:[UIImage imageNamed:@"PhotoIcon"] tag:0];
    
    lineItemsAdController.tabBarItem = item1;
    
    LineItemLogViewController *logsViewController = [[LineItemLogViewController alloc] init];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"Logs" image:[UIImage imageNamed:@"InfoIcon"] tag:1];
    
    logsViewController.tabBarItem = item2;
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:lineItemsAdController];
    [tabViewControllers addObject:logsViewController];
    
    [self setViewControllers: tabViewControllers];
}

@end
