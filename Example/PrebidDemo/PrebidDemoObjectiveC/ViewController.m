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
#import "MoPub.h"
#import "PrebidDemoObjectiveC-Swift.h"

@interface ViewController () <GADBannerViewDelegate, MPAdViewDelegate, MPInterstitialAdControllerDelegate, GAMBannerAdLoaderDelegate, GADCustomNativeAdLoaderDelegate, NativeAdDelegate, NativeAdEventDelegate>
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIView *adContainerView;

@property (nonatomic, strong) GAMBannerView *dfpView;
@property (nonatomic, strong) GAMRequest *request;
@property (nonatomic, strong) MPAdView *mopubAdView;
@property (nonatomic, strong) MPInterstitialAdController *mopubInterstitial;
@property (nonatomic, strong) BannerAdUnit *bannerUnit;
@property (nonatomic, strong) InterstitialAdUnit *interstitialUnit;
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) MPNativeAdRequest *mpNative;
@property (nonatomic, strong) MPNativeAd *mpAd;
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
    
    self.bannerUnit = [[BannerAdUnit alloc] initWithConfigId:@"6ace8c7d-88c0-4623-8117-75bc3f0a2e45" size:CGSizeMake(300, 250)];
    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4"];
    
//    Advanced interstitial support
//    self.interstitialUnit = [[InterstitialAdUnit alloc] initWithConfigId:@"625c6125-f19e-4d5b-95c5-55501526b2a4" minWidthPerc:50 minHeightPerc:70];
    
//    [self enableCOPPA];
//    [self addFirstPartyData:self.bannerUnit];
//    [self setStoredResponse];
//    [self setRequestTimeoutMillis];//
    
    if([self.adUnit isEqualToString:@"Banner"]) {
        self.bannerView.hidden = false;
        self.adContainerView.hidden = true;
        if ([self.adServer isEqualToString:@"DFP"]) {
            [self loadDFPBanner];
        } else if ([self.adServer isEqualToString:@"MoPub"]) {
            [self loadMoPubBanner];
        }
    } else if ([self.adUnit isEqualToString:@"Interstitial"]) {
        self.bannerView.hidden = false;
        self.adContainerView.hidden = true;
        if ([self.adServer isEqualToString:@"DFP"]) {
            [self loadDFPInterstitial];
        } else if ([self.adServer isEqualToString:@"MoPub"]) {
            [self loadMoPubInterstitial];
        }
    } else if ([self.adUnit isEqualToString:@"InAppNative"]) {
        self.bannerView.hidden = true;
        self.adContainerView.hidden = false;
        if ([self.adServer isEqualToString:@"DFP"]) {
            [self loadDFPPrebidNative];
        } else if ([self.adServer isEqualToString:@"MoPub"]) {
            [self loadMopubPrebidNative];
        }
    }
    // Do any additional setup after loading the view, typically from a nib.
}
    
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.bannerUnit stopAutoRefresh];
}
    
    
    
-(void) loadDFPBanner {
    
    [self.bannerUnit setAutoRefreshMillisWithTime:35000];
    self.dfpView = [[GAMBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
    self.dfpView.rootViewController = self;
    self.dfpView.adUnitID = @"/19968336/PrebidMobileValidator_Banner_All_Sizes";
    self.dfpView.delegate = self;
    [self.bannerView addSubview:self.dfpView];
    self.dfpView.backgroundColor = [UIColor redColor];
    self.request = [[GAMRequest alloc] init];

    [self.bannerUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dfpView loadRequest:self.request];
        });
    }];
}
    
-(void) loadDFPInterstitial {
    
    self.request = [[GAMRequest alloc] init];
    [self.interstitialUnit fetchDemandWithAdObject:self.request completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);

        [GAMInterstitialAd loadWithAdManagerAdUnitID:@"/19968336/PrebidMobileValidator_Interstitial" request:self.request completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                return;
            }
            [interstitialAd presentFromRootViewController:self];
        }];

    }];
}
    
-(void) loadMoPubBanner {
    
    MPMoPubConfiguration *configuration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"a935eac11acd416f92640411234fbba6"];
    
    [[MoPub sharedInstance] initializeSdkWithConfiguration:configuration completion:^{
        
    }];
    self.mopubAdView = [[MPAdView alloc] initWithAdUnitId:@"a935eac11acd416f92640411234fbba6" size:CGSizeMake(300, 250)];
    self.mopubAdView.delegate = self;
    
    [self.bannerView addSubview:self.mopubAdView];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self.bannerUnit fetchDemandWithAdObject:self.mopubAdView completion:^(enum ResultCode result) {         
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.mopubAdView loadAd];
    }];
}
    
-(void) loadMoPubInterstitial {
    
    MPMoPubConfiguration *configuration = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:@"2829868d308643edbec0795977f17437"];
    [[MoPub sharedInstance] initializeSdkWithConfiguration:configuration completion:nil];
    self.mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"2829868d308643edbec0795977f17437"];
    self.mopubInterstitial.delegate = self;
    [self.interstitialUnit fetchDemandWithAdObject:self.mopubInterstitial completion:^(enum ResultCode result) {
        NSLog(@"Prebid demand result %ld", (long)result);
        [self.mopubInterstitial loadAd];
    }];
    
    
}

-(void) enableCOPPA {
    Targeting.shared.subjectToCOPPA = true;
}

-(void) addFirstPartyData:(AdUnit *)adUnit {
    //Access Control List
    [Targeting.shared addBidderToAccessControlList: Prebid.bidderNameAppNexus];

    //global user data
    ContentDataObject *userData = [ContentDataObject new];
    userData.id = @"globalUserDataValue1";
    [Targeting.shared addUserDataObject:userData];

    //global context data
    ContentDataObject *appData = [ContentDataObject new];
    appData.id = @"globalContextDataValue1";
    [Targeting.shared addAppDataObject:appData];

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

-(void) setStoredResponse {
    Prebid.shared.storedAuctionResponse = @"111122223333";
}

-(void) setRequestTimeoutMillis {
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



#pragma mark :- Mopub delegates
git -(void) adViewDidLoadAd:(MPAdView *)view {
    NSLog(@"Ad received");
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"Ad ready");
    if (self.mopubInterstitial.ready) {
        [self.mopubInterstitial showFromViewController:self];
    }
}
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"Ad not ready");
}

#pragma mark Prebid NativeAd MoPub

-(void) loadMopubPrebidNative {
    [self removePreviousAds];
    [self createPrebidNativeView];
    [self loadNativeAssets];
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    self.mpNative = [MPNativeAdRequest requestWithAdUnitIdentifier:@"2674981035164b2db5ef4b4546bf3d49" rendererConfigurations:@[config]];

    MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
    self.mpNative.targeting = targeting;

    [self.nativeUnit fetchDemandWithAdObject:self.mpNative completion:^(enum ResultCode resultCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
              [self loadMoPub:self.mpNative];
          });
    }];

}

-(void) loadMoPub:(MPNativeAdRequest *)mpNative{
    [mpNative startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error == nil) {
            self.mpAd = response;
            Utils.shared.delegate = self;
            [Utils.shared findNativeWithAdObject:self.mpAd];
        }
    }];
}

#pragma mark Prebid NativeAd DFP

-(void) loadDFPPrebidNative {
    [self removePreviousAds];
    [self createPrebidNativeView];
    [self loadNativeAssets];
    GAMRequest *dfpRequest = [[GAMRequest alloc] init];
    [self.nativeUnit fetchDemandWithAdObject:dfpRequest completion:^(enum ResultCode result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadDFP:dfpRequest];
        });
    }];

}

-(void) loadDFP:(GAMRequest *)dfpRequest{
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:@"/19968336/Abhas_test_native_native_adunit" rootViewController:self adTypes:@[kGADAdLoaderAdTypeGAMBanner, kGADAdLoaderAdTypeCustomNative] options:@[]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:dfpRequest];
}

#pragma mark :- Native functions

-(void) createPrebidNativeView{
    UINib *adNib = [UINib nibWithNibName:@"NativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    _nativeAdView = [array firstObject];
    _nativeAdView.frame = CGRectMake(0, 0, _adContainerView.frame.size.width, 150 + self.view.frame.size.width * 400 / 600);
    [_adContainerView addSubview:_nativeAdView];
}

-(void) registerPrebidNativeView{
    self.prebidNativeAd.delegate = self;
    [self.prebidNativeAd registerViewWithView:self.nativeAdView clickableViews:@[self.nativeAdView.callToActionButton]];
}

-(void) loadNativeAssets{
    NativeAssetImage *image = [[NativeAssetImage alloc] initWithMinimumWidth:200 minimumHeight:200 required:true];
    image.type = ImageAsset.Main;

    NativeAssetImage *icon = [[NativeAssetImage alloc] initWithMinimumWidth:20 minimumHeight:20 required:true];
    icon.type = ImageAsset.Icon;

    NativeAssetTitle *title = [[NativeAssetTitle alloc] initWithLength:90 required:true];
    NativeAssetData *body = [[NativeAssetData alloc] initWithType:DataAssetDescription required:true];
    NativeAssetData *cta = [[NativeAssetData alloc] initWithType:DataAssetCtatext required:true];
    NativeAssetData *sponsored = [[NativeAssetData alloc] initWithType:DataAssetSponsored required:true];

    self.nativeUnit = [[NativeRequest alloc] initWithConfigId:@"25e17008-5081-4676-94d5-923ced4359d3" assets:@[icon,title,image,body,cta,sponsored]];
    self.nativeUnit.context = ContextType.Social;
    self.nativeUnit.placementType = PlacementType.FeedContent;
    self.nativeUnit.contextSubType = ContextSubType.Social;

    self.eventTrackers = [[NativeEventTracker alloc] initWithEvent:EventType.Impression methods:@[EventTracking.Image, EventTracking.js]];
    self.nativeUnit.eventtrackers = @[self.eventTrackers];

}

-(void) removePreviousAds{
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

-(void) renderPrebidNativeAd{
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

- (void)adLoader:(GADAdLoader *)adLoader didReceiveGAMBannerView:(GAMBannerView *)bannerView
{
    [self.nativeAdView addSubview:bannerView];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Prebid GADAdLoader failed %@", error.localizedDescription);
}

- (NSArray<NSValue *> *)validBannerSizesForAdLoader:(GADAdLoader *)adLoader
{
    return @[NSValueFromGADAdSize(kGADAdSizeBanner)];
}

#pragma mark : GADCustomNativeAdLoaderDelegate

- (NSArray<NSString *> *)customNativeAdFormatIDsForAdLoader:(GADAdLoader *)adLoader
{
    return @[@"11963183"];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveCustomNativeAd:(GADCustomNativeAd *)customNativeAd
{
    NSLog(@"Prebid GADAdLoader received customTemplageAd");
    Utils.shared.delegate = self;
    [Utils.shared findNativeWithAdObject:customNativeAd];
}

#pragma mark :- NativeAdDelegate Delegate

- (void)nativeAdLoadedWithAd:(NativeAd *)ad{
    NSLog(@"nativeAdLoadedWithAd");
    self.prebidNativeAd = ad;
    [self registerPrebidNativeView];
    [self renderPrebidNativeAd];
}
- (void)nativeAdNotFound{
    NSLog(@"nativeAdNotFound");
}
- (void)nativeAdNotValid{
    NSLog(@"nativeAdNotValid");
}

#pragma mark :- NativeAdEventDelegate Delegate

- (void)adDidExpireWithAd:(NativeAd *)ad{
    NSLog(@"adDidExpire");
}
- (void)adWasClickedWithAd:(NativeAd *)ad{
    NSLog(@"adWasClicked");
}
- (void)adDidLogImpressionWithAd:(NativeAd *)ad{
    NSLog(@"adDidLogImpression");
}

@end
