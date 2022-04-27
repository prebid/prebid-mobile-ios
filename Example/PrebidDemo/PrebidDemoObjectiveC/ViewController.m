/*   Copyright 2018-2019 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

@import GoogleMobileAds;
@import PrebidMobile;

#import "ViewController.h"
#import "ObjCDemoConstants.h"
#import "PrebidDemoObjectiveC-Swift.h"

@interface ViewController () <GADBannerViewDelegate, GAMBannerAdLoaderDelegate, GADCustomNativeAdLoaderDelegate, NativeAdDelegate, NativeAdEventDelegate>
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIView *adContainerView;

@property (nonatomic, strong) GAMBannerView *dfpView;
@property (nonatomic, strong) GAMRequest *request;
@property (nonatomic, strong) BannerAdUnit *bannerUnit;
@property (nonatomic, strong) InterstitialAdUnit *interstitialUnit;
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) NativeAd *prebidNativeAd;
@property (nonatomic, strong) NativeAdView *nativeAdView;
@property (nonatomic, strong) NativeRequest *nativeUnit;
@property (nonatomic, strong) NativeEventTracker *eventTrackers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Prebid.shared.prebidServerAccountId = @"bfa84af2-bd16-4d35-96ad-31c6bb888df0";
    Prebid.shared.prebidServerHost = PrebidHostAppnexus;
    Prebid.shared.shareGeoLocation = true;
    // NSError* err=nil;
    // [[Prebid shared] setCustomPrebidServerWithUrl:@"" error:&err];
    // if(err == nil)
    
    //    Advanced interstitial support
    //    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4" minWidthPerc:50 minHeightPerc:70];
    
    //    [self enableCOPPA];
    //    [self addFirstPartyData:self.bannerUnit];
    //    [self setStoredResponse];
    //    [self setRequestTimeoutMillis];
    
    if(self.adUnit == IntegrationAdFormat_Banner) {
        self.bannerView.hidden = false;
        self.adContainerView.hidden = true;
        if (self.adServer == IntegrationKind_OriginalGAM) {
            [self loadDFPBanner];
        }
    } else if (self.adUnit == IntegrationAdFormat_Interstitial) {
        self.bannerView.hidden = false;
        self.adContainerView.hidden = true;
        if (self.adServer == IntegrationKind_OriginalGAM) {
            [self loadDFPInterstitial];
        }
    } else if (self.adUnit == IntegrationAdFormat_NativeInApp) {
        self.bannerView.hidden = true;
        self.adContainerView.hidden = false;
        if (self.adServer == IntegrationKind_OriginalGAM) {
            [self loadDFPPrebidNative];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.bannerUnit stopAutoRefresh];
}

-(void)setupPrebidServerWith:(NSString *)storedResponse {
    Prebid.shared.accountID = ObjCDemoConstants.kPrebidAccountId;
    [Prebid.shared setCustomPrebidServerWithUrl:ObjCDemoConstants.kPrebidAWSServerURL error:nil];
    Prebid.shared.storedAuctionResponse = storedResponse;
}

-(void)setupBannerAdUnit {
    [self setupPrebidServerWith:ObjCDemoConstants.kBannerDisplayStoredResponse];
    self.bannerUnit = [[BannerAdUnit alloc] initWithConfigId:ObjCDemoConstants.kBannerDisplayStoredImpression
                                                        size:CGSizeMake(320, 50)];
    [self.bannerUnit setAutoRefreshMillisWithTime:35000];
}

-(void)setupInterstitialAdUnit {
    [self setupPrebidServerWith:ObjCDemoConstants.kInterstitialDisplayStoredResponse];
    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:ObjCDemoConstants.kInterstitialDisplayStoredImpression];
}

-(void)loadDFPBanner {
    [self setupBannerAdUnit];
    CGSize size = CGSizeMake(320, 50);
    self.dfpView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(size)];
    self.dfpView.adUnitID = ObjCDemoConstants.kGAMOriginalBannerDisplayAdUnitId;
    self.dfpView.rootViewController = self;
    self.dfpView.delegate = self;
    [self.bannerView addSubview:self.dfpView];
    
    for (NSLayoutConstraint* constraint in self.bannerView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = size.height;
        }
        
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = size.width;
        }
    }
    
    self.dfpView.backgroundColor = [UIColor redColor];
    self.request = [[GAMRequest alloc] init];
    
    [self.bannerUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dfpView loadRequest:self.request];
        });
    }];
}

-(void)loadDFPInterstitial {
    [self setupInterstitialAdUnit];
    self.request = [[GAMRequest alloc] init];
    [self.interstitialUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        
        [GAMInterstitialAd loadWithAdManagerAdUnitID:ObjCDemoConstants.kGAMInterstitialDisplayAdUnitId request:self.request completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                return;
            }
            [interstitialAd presentFromRootViewController:self];
        }];
    }];
}

-(void)enableCOPPA {
    Targeting.shared.coppa = @(1);
}

-(void)addFirstPartyData:(AdUnit *)adUnit {
    //Access Control List
    [Targeting.shared addBidderToAccessControlList: Prebid.bidderNameAppNexus];
    [Targeting.shared addUserDataWithKey:@"globalUserDataKey1" value:@"globalUserDataValue1"];
    [Targeting.shared addContextDataWithKey:@"globalContextDataKey1" value:@"globalContextDataValue1"];
    //global user data
    PBMORTBContentData *userData = [PBMORTBContentData new];
    userData.id = @"globalUserDataValue1";
    [adUnit addUserData:@[userData]];
    
    //global context data
    PBMORTBContentData *appData = [PBMORTBContentData new];
    appData.id = @"globalContextDataValue1";
    [adUnit addAppContentData:@[appData]];
    
    //adunit context data
    [adUnit addContextDataWithKey:@"adunitContextDataKey1" value:@"adunitContextDataValue1"];
    
    //global context keywords
    [Targeting.shared addContextKeyword:@"globalContextKeywordValue1"];
    [Targeting.shared addContextKeyword:@"globalContextKeywordValue2"];
    
    //global user keywords
    [Targeting.shared addUserKeyword:@"globalUserKeywordValue1"];
    [Targeting.shared addUserKeyword:@"globalUserKeywordValue2"];
    
    //adunit context keywords
    [adUnit addContextKeyword:@"adunitContextKeywordValue1"];
    [adUnit addContextKeyword:@"adunitContextKeywordValue2"];
}

-(void)setStoredResponse {
    Prebid.shared.storedAuctionResponse = @"111122223333";
}

-(void)setRequestTimeoutMillis {
    Prebid.shared.timeoutMillis = 5000;
}

#pragma mark :- DFP banner delegates

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"Ad received");
    
    [AdViewUtils findPrebidCreativeSize:bannerView
                                success:^(CGSize size) {
        if ([bannerView isKindOfClass:[GAMBannerView class]]) {
            GAMBannerView *dfpBannerView = (GAMBannerView *)bannerView;
            
            [dfpBannerView resize:GADAdSizeFromCGSize(size)];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", error.localizedDescription);
}

#pragma mark Prebid NativeAd DFP

-(void)loadDFPPrebidNative {
    [self setupPrebidServerWith:ObjCDemoConstants.kNativeStoredResponse];
    [self removePreviousAds];
    [self createPrebidNativeView];
    [self loadNativeAssets];
    GAMRequest *dfpRequest = [[GAMRequest alloc] init];
    [self.nativeUnit fetchDemandWithAdObject:dfpRequest completion:^(enum ResultCode result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:ObjCDemoConstants.kGAMNativeAdUnitId
                                               rootViewController:self
                                                          adTypes:@[kGADAdLoaderAdTypeCustomNative]
                                                          options:@[]];
            self.adLoader.delegate = self;
            [self.adLoader loadRequest:dfpRequest];
        });
    }];
}

#pragma mark :- Native functions

-(void)createPrebidNativeView {
    UINib *adNib = [UINib nibWithNibName:@"NativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    _nativeAdView = [array firstObject];
    _nativeAdView.frame = CGRectMake(0, 0, _adContainerView.frame.size.width, 150 + self.view.frame.size.width * 400 / 600);
    [_adContainerView addSubview:_nativeAdView];
}

-(void)registerPrebidNativeView {
    self.prebidNativeAd.delegate = self;
    [self.prebidNativeAd registerViewWithView:self.nativeAdView clickableViews:@[self.nativeAdView.callToActionButton]];
}

-(void)loadNativeAssets {
    NativeAssetImage *image = [[NativeAssetImage alloc] initWithMinimumWidth:200 minimumHeight:200 required:true];
    image.type = ImageAsset.Main;
    
    NativeAssetImage *icon = [[NativeAssetImage alloc] initWithMinimumWidth:20 minimumHeight:20 required:true];
    icon.type = ImageAsset.Icon;
    
    NativeAssetTitle *title = [[NativeAssetTitle alloc] initWithLength:90 required:true];
    NativeAssetData *body = [[NativeAssetData alloc] initWithType:DataAssetDescription required:true];
    NativeAssetData *cta = [[NativeAssetData alloc] initWithType:DataAssetCtatext required:true];
    NativeAssetData *sponsored = [[NativeAssetData alloc] initWithType:DataAssetSponsored required:true];
    
    self.eventTrackers = [[NativeEventTracker alloc] initWithEvent:EventType.Impression
                                                           methods:@[EventTracking.Image, EventTracking.js]];
    
    self.nativeUnit = [[NativeRequest alloc] initWithConfigId:ObjCDemoConstants.kNativeStoredImpression
                                                       assets:@[title, icon, image, sponsored, body, cta]
                                                eventTrackers:@[self.eventTrackers]];
    self.nativeUnit.context = ContextType.Social;
    self.nativeUnit.placementType = PlacementType.FeedContent;
    self.nativeUnit.contextSubType = ContextSubType.Social;
}

-(void)removePreviousAds {
    if (_nativeAdView != nil) {
        _nativeAdView.iconImageView = nil;
        _nativeAdView.mainImageView = nil;
        [_nativeAdView removeFromSuperview];
        _nativeAdView = nil;
    }
    if (_prebidNativeAd != nil) {
        _prebidNativeAd = nil;
    }
    if (_bannerView != nil) {
        _bannerView = nil;
    }
}

#pragma mark :- Rendering Prebid Native

-(void)renderPrebidNativeAd {
    self.nativeAdView.titleLabel.text = self.prebidNativeAd.title;
    self.nativeAdView.bodyLabel.text = self.prebidNativeAd.text;
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * dataIcon = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.prebidNativeAd.iconUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nativeAdView.iconImageView.image = [UIImage imageWithData: dataIcon];
        });
    });
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * dataMainImage = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.prebidNativeAd.imageUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nativeAdView.mainImageView.image = [UIImage imageWithData: dataMainImage];
        });
    });
    [self.nativeAdView.callToActionButton setTitle:self.prebidNativeAd.callToAction forState:UIControlStateNormal];
    self.nativeAdView.sponsoredLabel.text = self.prebidNativeAd.sponsoredBy;
}

#pragma mark :- DFP Native Delegate GAMBannerAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveGAMBannerView:(GAMBannerView *)bannerView {
    [self.nativeAdView addSubview:bannerView];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Prebid GADAdLoader failed %@", error.localizedDescription);
}

- (NSArray<NSValue *> *)validBannerSizesForAdLoader:(GADAdLoader *)adLoader {
    return @[NSValueFromGADAdSize(kGADAdSizeBanner)];
}

#pragma mark : GADCustomNativeAdLoaderDelegate

- (NSArray<NSString *> *)customNativeAdFormatIDsForAdLoader:(GADAdLoader *)adLoader {
    return @[ObjCDemoConstants.kGAMCustomNativeAdFormatId];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveCustomNativeAd:(GADCustomNativeAd *)customNativeAd {
    NSLog(@"Prebid GADAdLoader received customTemplageAd");
    Utils.shared.delegate = self;
    [Utils.shared findNativeWithAdObject:customNativeAd];
}

#pragma mark :- NativeAdDelegate Delegate

- (void)nativeAdLoadedWithAd:(NativeAd *)ad {
    NSLog(@"nativeAdLoadedWithAd");
    self.prebidNativeAd = ad;
    [self registerPrebidNativeView];
    [self renderPrebidNativeAd];
}
- (void)nativeAdNotFound {
    NSLog(@"nativeAdNotFound");
}

- (void)nativeAdNotValid {
    NSLog(@"nativeAdNotValid");
}

#pragma mark :- NativeAdEventDelegate Delegate

- (void)adDidExpireWithAd:(NativeAd *)ad {
    NSLog(@"adDidExpire");
}

- (void)adWasClickedWithAd:(NativeAd *)ad {
    NSLog(@"adWasClicked");
}

- (void)adDidLogImpressionWithAd:(NativeAd *)ad {
    NSLog(@"adDidLogImpression");
}

@end
