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
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ScreenGrab" style:UIBarButtonItemStylePlain target:self action:@selector(captureScreen)];
    
    [NSURLProtocol registerClass:[LineItemURLProtocol class]];
    
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

-(void) requestLineItems {
    
    // Retrieve saved values from NSUserDefaults and setup instance variables
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    self.bidPrices = [[NSUserDefaults standardUserDefaults] arrayForKey:kBidPriceKey];
    
    self.isBanner = [adFormatName isEqualToString:kBannerString];
    self.isInterstitial = [adFormatName isEqualToString:kInterstitialString];
    self.isMoPub = [adServerName isEqualToString:kMoPubString];
    self.isDFP = [adServerName isEqualToString:kDFPString];
    
    self.adSize = CGSizeZero;
    GADAdSize GADAdSize = kGADAdSizeInvalid;
    if ([adSizeString isEqualToString:kBannerSizeString]) {
        self.adSize = CGSizeMake(kBannerSizeWidth, kBannerSizeHeight);
        GADAdSize = kGADAdSizeBanner;
    } else if ([adSizeString isEqualToString:kMediumRectangleSizeString]) {
        self.adSize = CGSizeMake(kMediumRectangleSizeWidth, kMediumRectangleSizeHeight);
        GADAdSize = kGADAdSizeMediumRectangle;
    } else if ([adSizeString isEqualToString:kInterstitialSizeString]) {
        self.adSize = CGSizeMake(kInterstitialSizeWidth, kInterstitialSizeHeight);
    }
    
    /* For each of the bid prices generate the keywords dictionary
     * Then request the ad server (MoPub or DFP) for the ad format (Banner or Insterstitial)
     */
    for (NSString *bidPrice in self.bidPrices) {
        self.keywordsDictionary = [LineItemKeywordsManager keywordsWithBidPrice:[bidPrice doubleValue]];
        
        if (self.isMoPub && self.isBanner) {
            [self testMoPubBannerAdViewWithAdUnitID:adUnitID adSize:self.adSize andKeywords:[self formatKeywordsForMoPub]];
        } else if (self.isDFP && self.isBanner) {
            [self testDFPBannerAdViewWithAdUnitID:adUnitID adSize:GADAdSize andKeywords:self.keywordsDictionary];
        } else if (self.isMoPub && self.isInterstitial) {
            [self testMoPubInterstitialWithAdUnitID:adUnitID];
        }
    }
    
}

#pragma mark - MPAdViewDelegate
- (void)adViewDidLoadAd:(MPAdView *)view {
    [view stopAutomaticallyRefreshingContents];
    //[self.bannerTableView reloadData];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    NSLog(@"ad Failed to load");
    [view stopAutomaticallyRefreshingContents];
    
    NSUInteger index = [self.adViews indexOfObject:view];
    self.adViews[index] = @(0);
    //[self.bannerTableView reloadData];
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}


#pragma mark - GADBannerViewDelegate
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSUInteger index = [self.adViews indexOfObject:bannerView.superview];
    self.adViews[index] = @(0);
    //[self.bannerTableView reloadData];
}

#pragma mark - MPInterstitialAdControllerDelegate
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    // [self formatAndShowInterstitial:interstitial withMessage:@"Intersitial failed to load at bid $" andColor:[UIColor redColor]];
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    if (self.interstitial.ready) {
        // [self.interstitial showFromViewController:self];
    }
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    //[self formatAndShowInterstitial:interstitial withMessage:@"Success! Interstitial loaded at $" andColor:[UIColor greenColor]];
}

// Banner testing functions
- (void)testMoPubBannerAdViewWithAdUnitID:(NSString *)adUnitID
                                   adSize:(CGSize)adSize
                              andKeywords:(NSString *)keywords {
    MPAdView *adView = [[MPAdView alloc] initWithAdUnitId:adUnitID
                                                     size:adSize];
    adView.delegate = self;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - adSize.width) / 2.0;
    adView.frame = CGRectMake(x, kAdLocationY, adSize.width, adSize.height);
    
    adView.keywords = keywords;
    [self.adViews addObject:adView];
    
    [adView loadAd];
}

- (void)testDFPBannerAdViewWithAdUnitID:(NSString *)adUnitID
                                 adSize:(GADAdSize)adSize
                            andKeywords:(NSDictionary *)keywords {
    self.instantAdView = [[DFPBannerView alloc] initWithAdSize:adSize];
    self.instantAdView.adUnitID = adUnitID;
    //self.instantAdView.rootViewController = self;
    self.instantAdView.delegate = self;
    
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - adSize.size.width) / 2.0;
    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(x, kAdLocationY, adSize.size.width, adSize.size.height)];
    [bannerView addSubview:self.instantAdView];
    [self.adViews addObject:bannerView];
    
    NSString *widthQuery = [NSString stringWithFormat:@"?width=%d&height=%d", (int)adSize.size.width, (int)adSize.size.height];
    NSString *lineItemTestURL = [@"https://pricecheck.tonycabal.com/line-item-test/index.php" stringByAppendingString:widthQuery];
    NSString *encodedURL = [self urlencode:lineItemTestURL];
    NSString *doubleEncodedURL = [self urlencode:encodedURL];
    
    NSMutableDictionary *mutableKeywords = [[NSMutableDictionary alloc] init];
    [mutableKeywords addEntriesFromDictionary:keywords];
    [mutableKeywords setObject:doubleEncodedURL forKey:@"hb_pb_adurl_enc"];
    
    DFPRequest *request = [DFPRequest request];
    request.customTargeting = mutableKeywords;
    
    [self.instantAdView loadRequest:request];
}

// Interstitial testing function
- (void)testMoPubInterstitialWithAdUnitID:(NSString *)adUnitID {
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adUnitID];
    self.interstitial.delegate = self;
}

// Helper function to properly encode the url
- (NSString *)urlencode:(NSString *)string {
    
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

// Helper function to format the keywords for MoPub call
- (NSString *)formatKeywordsForMoPub {
    NSString *keywordsString = @"";
    for (NSString *key in self.keywordsDictionary) {
        NSString *formatKey = [key stringByAppendingString:@":"];
        NSString *formatKeyword = [formatKey stringByAppendingString:self.keywordsDictionary[key]];
        keywordsString = [keywordsString stringByAppendingString:[formatKeyword stringByAppendingString:@","]];
    }
    NSString *sizeQuery = [NSString stringWithFormat:@"hb_size:%dx%d", (int)self.adSize.width, (int)self.adSize.height];
    NSString *keywordsWithPBParams = [keywordsString stringByAppendingString:sizeQuery];
    
    return keywordsWithPBParams;
}




@end
