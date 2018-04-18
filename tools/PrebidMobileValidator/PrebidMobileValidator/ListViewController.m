//
//  ListViewController.m
//  PrebidTestApp
//
//  Created by Punnaghai Puviarasu on 4/3/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "ListViewController.h"
#import "LineItemsTabController.h"
#import "PBSettingsViewController.h"
#import "PBVTableViewCell.h"
#import "LineItemsConstants.h"
#import "LineItemKeywordsManager.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

@import GoogleMobileAds;


#define CellReuseID @"ReuseCell"

@interface ListViewController () <MPAdViewDelegate,MPInterstitialAdControllerDelegate,GADBannerViewDelegate>

@property (strong, nonatomic) NSArray *items;

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

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Prebid Validator";
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.items = [[NSArray alloc] initWithObjects:@"AdServer Setup Validation", @"PrebidServer Configuration Validation",@"PrebidSDK Validation", nil];
    
    
    UITableView *tableView = (UITableView *)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"PBVTableViewCell" bundle:nil] forCellReuseIdentifier:CellReuseID];
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //[self requestLineItems];
    
//    LineItemsRequestor *lineItemRequestor = [[LineItemsRequestor alloc] init];
//
//    lineItemRequestor.delegate = self;
//
//    [lineItemRequestor requestLineItems];
//
    
    //LineItemsTabController *lineItemsTabController = [[LineItemsTabController alloc] init];
    
    //[lineItemsTabController view];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PBVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseID forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *item = [self.items objectAtIndex:indexPath.row];
    
    cell.progressImage.image = [UIImage imageNamed:@"YellowIcon"];
    
    cell.lblValidator.text=item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0){
        LineItemsTabController *lineItemsTabController = [[LineItemsTabController alloc] init];
        
        [self.navigationController pushViewController:lineItemsTabController animated:YES];
    } if(indexPath.row == 2){
        PBSettingsViewController *pbSettingsViewController = [[PBSettingsViewController alloc] init];
        
        [self.navigationController pushViewController:pbSettingsViewController animated:YES];
    }
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
    [mutableKeywords setObject:doubleEncodedURL forKey:@"pb_adurl_enc"];
    
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
