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

#import "BannerTestsViewController.h"
#import "PBVSharedConstants.h"
#import <GoogleMobileAds/DFPBannerView.h>
#import "MPAdView.h"
#import "PrebidMobile/PrebidMobile.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface BannerTestsViewController () <GADBannerViewDelegate, MPAdViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MPAdView *mopubAdView;
@property (strong, nonatomic) DFPBannerView *dfpAdView;
@property (strong, nonatomic) UIView *adContainerView;
@property (strong, nonatomic) NSDictionary *settings;

@end

@implementation BannerTestsViewController

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    _settings = settings;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupEmailConfigButton];
}

-(void) setupEmailConfigButton
{
    UIBarButtonItem *emailConfig = [[UIBarButtonItem alloc]init];
    emailConfig.style = UIBarButtonItemStylePlain;
    emailConfig.title = @"Email Config";
    emailConfig.target = self;
    emailConfig.action = NSSelectorFromString(@"emailConfig:");
    self.navigationItem.rightBarButtonItem = emailConfig;
}

- (void) emailConfig:(id) sender
{
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Step by step instruction to setup your Prebid Mobile"];
        NSMutableString *body = [[NSMutableString alloc]initWithString:@""];
        [body appendString: @"Hi, \n\n"];
        [body appendString:@"Please follow the instructions below to set up your Prebid Mobile.\n\n"];
        [body appendString:@"Step 1: as early as possible in the lifecycle of your app, create the ad unit and register with Prebid Mobile: \n"];
        NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
        NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBAccountKey];
        [body appendString:[NSString stringWithFormat: @"PBBannerAdUnit *adUnit = [[PBBannerAdUnit alloc]initWithAdUnitIdentifier:@\"Home\" andConfigId:@\"%@\"];\n", configId]];
        [body appendString:@"[adUnit addSize: CGSizeMake(300, 250)];\n"];
        [body appendString:@"NSArray *adUnits = [NSArray arrayWithObjects:adUnit, nil];\n"];
        [body appendString:[NSString stringWithFormat:@"[PrebidMobile registerAdUnits:adUnits withAccountId:@\"%@\" withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerMoPub];", accountId]];
        [body appendString:@"\n\nStep 2: create your banner ad view and apply prebid bids on the object:\n"];
        NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
        [body appendString:[NSString stringWithFormat:@"MPAdView *mopubAdView = [[MPAdView alloc] initWithAdUnitId:@\"%@\" size:CGSizeMake(300, 250)];\n", adUnitID]];
        [body appendString:@"Configure your mopubAdView...\n"];
        [body appendString:[NSString stringWithFormat:@"[PrebidMobile setBidKeywordsOnAdObject:mopubAdView withAdUnitId:@\"Home\" withTimeout:600 completionHandler:^{[mopubAdView loadAd];}];"]];
        [mailViewController setMessageBody:body isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        UIAlertController *alert = [[UIAlertController alloc] init];
        alert.title = @"Uable to send email";
        alert.message = @"Please set up an email account on your device.";
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:alertAction];
        [self presentViewController: alert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *adServer = [self.settings objectForKey:kAdServerNameKey];
    NSString *adUnitId = [self.settings objectForKey:kAdUnitIdKey];
    self.title = [adServer stringByAppendingString:@" Banner"];
    
    NSString *size = [self.settings objectForKey:kAdSizeKey];
    NSArray *widthHeight = [size componentsSeparatedByString:@"x"];
    double width = [widthHeight[0] doubleValue];
    double height = [widthHeight[1] doubleValue];
    
    _adContainerView = [[UIView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width - width) / 2, 100, width, height)];
    [self.view addSubview:_adContainerView];
    
    if ([adServer isEqualToString:kMoPubString]) {
        _mopubAdView = [[MPAdView alloc] initWithAdUnitId:adUnitId
                                                     size:CGSizeMake(width, height)];
        _mopubAdView.delegate = self;
        [_adContainerView addSubview:_mopubAdView];
        
        [PrebidMobile setBidKeywordsOnAdObject:self.mopubAdView withAdUnitId:adUnitId withTimeout:600 completionHandler:^{
            [self.mopubAdView loadAd];
        }];
    } else if ([adServer isEqualToString:kDFPString]) {
        _dfpAdView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width, height))];
        _dfpAdView.adUnitID = adUnitId;
        _dfpAdView.rootViewController = self;
        _dfpAdView.delegate = self;
        
        [_adContainerView addSubview:_dfpAdView];
        
        [PrebidMobile setBidKeywordsOnAdObject:_dfpAdView withAdUnitId:adUnitId withTimeout:600 completionHandler:^{
            [self.dfpAdView loadRequest:[DFPRequest request]];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(DFPBannerView *)view {

}

- (void)adView:(DFPBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
}

#pragma mark MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
}

@end
