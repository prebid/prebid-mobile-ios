//
//  RenderingBannerViewController.m
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import "RenderingBannerViewController.h"

@import PrebidMobile;
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileMoPubAdapters;

@interface RenderingBannerViewController () <BannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *adView;

@property (strong, nullable) BannerView *bannerView;

@end

@implementation RenderingBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initRendering];
    
    [self loadInAppBanner];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mar - Load Ad

- (void)initRendering {
    PrebidRenderingConfig.shared.accountID = @"0689a263-318d-448b-a3d4-b02e8a709d9d";
    [PrebidRenderingConfig.shared setCustomPrebidServerWithUrl:@"https://prebid.openx.net/openrtb2/auction" error:nil];
    
    [NSUserDefaults.standardUserDefaults setValue:@"123" forKey:@"IABTCF_CmpSdkID"];
    [NSUserDefaults.standardUserDefaults setValue:@"0" forKey:@"IABTCF_gdprApplies"];
}

- (void)loadInAppBanner {
    const CGSize size = CGSizeMake(320, 50);
    const CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    self.bannerView = [[BannerView alloc] initWithFrame:frame
                                               configID:@"50699c03-0910-477c-b4a4-911dbe2b9d42"
                                                 adSize:size];
    
    [self.bannerView loadAd];
    self.bannerView.delegate = self;
    
    [self.adView addSubview:self.bannerView];
}

#pragma mark - BannerViewDelegate

- (UIViewController * _Nullable)bannerViewPresentationController {
    return self;
}

- (void)bannerView:(BannerView *)bannerView didReceiveAdWithAdSize:(CGSize)adSize {
    NSLog(@"InApp bannerView:didReceiveAdWithAdSize");
}

- (void)bannerView:(BannerView *)bannerView didFailToReceiveAdWith:(NSError *)error {
    NSLog(@"InApp bannerView:didFailToReceiveAdWith: %@", [error localizedDescription]);

}


@end
