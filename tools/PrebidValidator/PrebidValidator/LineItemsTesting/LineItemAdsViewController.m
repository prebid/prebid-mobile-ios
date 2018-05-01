//
//  LineItemAdsViewController.m
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 24/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

@import GoogleMobileAds;

#import "LineItemAdsViewController.h"
#import "PBVSharedConstants.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import "LineItemKeywordsManager.h"

@interface LineItemAdsViewController () <MPAdViewDelegate,
                                         MPInterstitialAdControllerDelegate,
                                         GADBannerViewDelegate,
                                         UITableViewDataSource,
                                         UITableViewDelegate>

@property (nonatomic, strong) MPInterstitialAdController *interstitial;

@property (nonatomic, strong) DFPBannerView *instantAdView;

@property (nonatomic, strong) NSMutableDictionary *bidPriceToCell;
@property (nonatomic, strong) NSArray *bidPrices;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *keywordsDictionary;
@property (nonatomic, strong) NSString *keywordsString;

@property (nonatomic, strong) NSMutableArray *adViews;

@property (nonatomic, strong) UITableView *interstitialTableView;
@property (nonatomic, strong) UITableView *bannerTableView;

@property (nonatomic, assign) BOOL isBanner;
@property (nonatomic, assign) BOOL isInterstitial;
@property (nonatomic, assign) BOOL isMoPub;
@property (nonatomic, assign) BOOL isDFP;

@property (nonatomic, assign) CGSize adSize;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation LineItemAdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Line items";
    
    // Retrieve saved values from NSUserDefaults and setup instance variables
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    _bidPrices = [[NSUserDefaults standardUserDefaults] arrayForKey:kBidPriceKey];
    
    _isBanner = [adFormatName isEqualToString:kBannerString];
    _isInterstitial = [adFormatName isEqualToString:kInterstitialString];
    _isMoPub = [adServerName isEqualToString:kMoPubString];
    _isDFP = [adServerName isEqualToString:kDFPString];
    
    _adViews = [[NSMutableArray alloc] init];
    
    _adSize = CGSizeZero;
    GADAdSize GADAdSize = kGADAdSizeInvalid;
    if ([adSizeString isEqualToString:kBannerSizeString]) {
        _adSize = CGSizeMake(kBannerSizeWidth, kBannerSizeHeight);
        GADAdSize = kGADAdSizeBanner;
    } else if ([adSizeString isEqualToString:kMediumRectangleSizeString]) {
        _adSize = CGSizeMake(kMediumRectangleSizeWidth, kMediumRectangleSizeHeight);
        GADAdSize = kGADAdSizeMediumRectangle;
    } else if ([adSizeString isEqualToString:kInterstitialSizeString]) {
        _adSize = CGSizeMake(kInterstitialSizeWidth, kInterstitialSizeHeight);
    }
    
    // Setup banner or interstital table view depending on format chosen
    if (self.isBanner) {
        _bannerTableView = [[UITableView alloc] init];
        [self setupTableView:_bannerTableView];
    } else if (self.isInterstitial) {
        _interstitialTableView = [[UITableView alloc] init];
        [self setupTableView:_interstitialTableView];
        self.bidPriceToCell = [[NSMutableDictionary alloc] init];
    }

    /* For each of the bid prices generate the keywords dictionary
     * Then request the ad server (MoPub or DFP) for the ad format (Banner or Insterstitial)
     */
    for (NSString *bidPrice in self.bidPrices) {

        if (self.isMoPub && self.isBanner) {
            NSDictionary *keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:[bidPrice doubleValue] forSize:adSizeString usingLocalCache:false];
            [self testMoPubBannerAdViewWithAdUnitID:adUnitID adSize:self.adSize andKeywords:keywords];
        } else if (self.isDFP && self.isBanner) {
            [self testDFPBannerAdViewWithAdUnitID:adUnitID adSize:GADAdSize andKeywords:self.keywordsDictionary];
        } else if (self.isMoPub && self.isInterstitial) {
            [self testMoPubInterstitialWithAdUnitID:adUnitID];
        }
        
    }
}

// Table initializer method, properties are the same for banner and interstitial
- (void)setupTableView:(UITableView *)tableView {
    tableView.frame = self.view.frame;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.backgroundColor = [UIColor whiteColor];
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (tableView == self.bannerTableView) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kAdLabelLocationX, kAdLabelLocationY, self.view.frame.size.width, kAdTitleLabelHeight)];
        title.font = [UIFont boldSystemFontOfSize:16];
        title.textColor = [UIColor blackColor];
        [title setText:[@"$" stringByAppendingString:[self.bidPrices objectAtIndex:indexPath.row]]];
        [cell.contentView addSubview:title];

        // Show ad view if it loaded, otherwise show the ad failed label in its place
        if ([[self.adViews objectAtIndex:indexPath.row] isKindOfClass:[UIView class]]) {
            [cell.contentView addSubview:[self.adViews objectAtIndex:indexPath.row]];
        } else {
            UILabel *adFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAdLabelLocationX, kAdLocationY, self.view.frame.size.width, kAdFailedLabelHeight)];
            adFailedLabel.lineBreakMode = NSLineBreakByWordWrapping;
            adFailedLabel.numberOfLines = 0;
            adFailedLabel.textColor = [UIColor blackColor];
            [adFailedLabel setText:@"Ad failed to load.\nYour line items do not cover this price." ];
            [cell.contentView addSubview:adFailedLabel];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    } else if (tableView == self.interstitialTableView) {
        cell.textLabel.text = [@"Click here to test interstitial for $" stringByAppendingString:[self.bidPrices objectAtIndex:indexPath.row]];
        double bidPriceDouble = [[self.bidPrices objectAtIndex:indexPath.row] doubleValue];
        [self.bidPriceToCell setObject:cell forKey:@(bidPriceDouble)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bidPrices count];
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isBanner) {
        return self.adSize.height + kAdLocationY + kAdMargin;
    }
    return kAdLocationY + kAdMargin;
}

// This ensures the separators do not have any inset
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only the interstitial rows are selectable, the banner rows are just for display
    if (tableView == self.bannerTableView) {
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    NSRange range = [cellText rangeOfString:@"$"];
    NSString *bidPrice = [cellText substringFromIndex:range.location + 1];
//    self.keywordsDictionary = [LineItemKeywordsManager sharedManager] keywordsWithBidPrice:[bidPrice doubleValue]];
//    self.interstitial.keywords = [self formatKeywordsForMoPub];
    [self.interstitial loadAd];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

// Helper function to format the keywords for MoPub call

#pragma mark - MPAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view {
    [view stopAutomaticallyRefreshingContents];
    [self.bannerTableView reloadData];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view {
    NSLog(@"ad Failed to load");
    [view stopAutomaticallyRefreshingContents];
    
    NSUInteger index = [self.adViews indexOfObject:view];
    self.adViews[index] = @(0);
    [self.bannerTableView reloadData];
}

#pragma mark - GADBannerViewDelegate
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSUInteger index = [self.adViews indexOfObject:bannerView.superview];
    self.adViews[index] = @(0);
    [self.bannerTableView reloadData];
}

#pragma mark - MPInterstitialAdControllerDelegate
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    [self formatAndShowInterstitial:interstitial withMessage:@"Intersitial failed to load at bid $" andColor:[UIColor redColor]];
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:self];
    }
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    [self formatAndShowInterstitial:interstitial withMessage:@"Success! Interstitial loaded at $" andColor:[UIColor greenColor]];
}

// Banner testing functions
- (void)testMoPubBannerAdViewWithAdUnitID:(NSString *)adUnitID
                                   adSize:(CGSize)adSize
                              andKeywords:(NSDictionary *)keywordsDict {
    NSString *keywordsString = @"";
    // Todo set keywords on the object 
//    for (NSString *key in keywordsDict) {
//        NSString *formatKey = [key stringByAppendingString:@":"];
//        NSString *formatKeyword = [formatKey stringByAppendingString:self.keywordsDictionary[key]];
//        keywordsString = [keywordsString stringByAppendingString:[formatKeyword stringByAppendingString:@","]];
//    }
    
    MPAdView *adView = [[MPAdView alloc] initWithAdUnitId:adUnitID
                                                     size:adSize];
    adView.delegate = self;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - adSize.width) / 2.0;
    adView.frame = CGRectMake(x, kAdLocationY, adSize.width, adSize.height);

    adView.keywords = keywordsString;
    [self.adViews addObject:adView];

    [adView loadAd];
}

- (void)testDFPBannerAdViewWithAdUnitID:(NSString *)adUnitID
                                 adSize:(GADAdSize)adSize
                            andKeywords:(NSDictionary *)keywords {
    self.instantAdView = [[DFPBannerView alloc] initWithAdSize:adSize];
    self.instantAdView.adUnitID = adUnitID;
    self.instantAdView.rootViewController = self;
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

// Format success and error message functions
- (void)formatAndShowInterstitial:(MPInterstitialAdController *)interstitial
                      withMessage:(NSString *)message
                         andColor:(UIColor *)color {
    NSString *keywords = interstitial.keywords;
    NSRange range = [keywords rangeOfString:@"pb_1c:"];
    NSString *endOfStringFromBidPrice = [keywords substringFromIndex:range.location + 6];
    NSArray *components = [endOfStringFromBidPrice componentsSeparatedByString:@","];
    NSString *bidPrice = components[0];
    
    double bidPriceDouble = [bidPrice doubleValue];
    UITableViewCell *cell = [self.bidPriceToCell objectForKey:@(bidPriceDouble)];
    cell.textLabel.textColor = color;
    cell.textLabel.text = [message stringByAppendingString:bidPrice];
    [cell setSelected:NO];
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

@end
