/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "BannerTestsViewController.h"
#import "Constants.h"
#import "InterstitialTestsViewController.h"
#import "SettingsViewController.h"
#import "VideoTestsViewController.h"

#import <CMPReference/CMPStorage.h>
#import <CMPReference/CMPConsentViewController.h>
#import <PrebidMobile/PBBannerAdUnit.h>
#import <PrebidMobile/PBException.h>
#import <PrebidMobile/PBInterstitialAdUnit.h>
#import <PrebidMobile/PrebidMobile.h>
#import <PrebidMobile/PBTargetingParams.h>

static NSString *const kSeeAdButtonTitle = @"See Ad";
static NSString *const kAdSettingsTableViewReuseId = @"AdSettingsTableItem";

static CGFloat const kRightMargin = 15;

@interface SettingsViewController () <CMPConsentViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *settingsTableView;
@property (strong, nonatomic) NSArray *generalSettingsData;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableDictionary *generalSettingsFields;
@property (strong) CMPStorage *consentStorageVC;

@property (strong) UIButton *nextButton;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _settingsTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _settingsTableView.dataSource = self;
    _settingsTableView.delegate = self;
    
    [self.view addSubview:_settingsTableView];
    _generalSettingsData = @[kAdServer, kAdType, kSize];
    [self initializeGeneralSettingsFields];
    
    _sectionHeaders = @[@"General"];//, @"Targeting", @"Custom Keywords"];
    
    UIBarButtonItem *previewAdButton = [[UIBarButtonItem alloc] initWithTitle:kSeeAdButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(previewAdButtonClicked:)];
    
    self.navigationItem.rightBarButtonItem = previewAdButton;
    
    _consentStorageVC = [[CMPStorage alloc] init];
    
    if(_consentStorageVC.cmpPresent == NO){
        UIBarButtonItem *consentButton = [[UIBarButtonItem alloc] initWithTitle:@"Get Consent" style:UIBarButtonItemStylePlain target:self action:@selector(didPressNext:)];
        
        self.navigationItem.leftBarButtonItem = consentButton;
    }
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeGeneralSettingsFields {
    _generalSettingsFields = [[NSMutableDictionary alloc] init];

    UISegmentedControl *adServerSegControl = [[UISegmentedControl alloc] initWithItems:@[kDFPAdServer, kMoPubAdServer, kAdformAdServer]];
    adServerSegControl.selectedSegmentIndex = 0;
    [adServerSegControl addTarget:self
                           action:@selector(adServerClicked:)
                 forControlEvents:UIControlEventValueChanged];
    UISegmentedControl *adTypeSegControl = [[UISegmentedControl alloc] initWithItems:@[kBanner, kInterstitial]];
    adTypeSegControl.clipsToBounds = true;
    adTypeSegControl.selectedSegmentIndex = 0;

    UITextField *placementIdTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    placementIdTextField.placeholder = kDefaultPlacementId;
    placementIdTextField.text = kDefaultPlacementId;
    placementIdTextField.textAlignment = NSTextAlignmentRight;

    UITextField *sizeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    sizeTextField.placeholder = kDefaultSize;
    sizeTextField.text = kDefaultSize;
    sizeTextField.textAlignment = NSTextAlignmentRight;

    [_generalSettingsFields setObject:adServerSegControl forKey:kAdServer];
    [_generalSettingsFields setObject:adTypeSegControl forKey:kAdType];
    [_generalSettingsFields setObject:placementIdTextField forKey:kPlacementId];
    [_generalSettingsFields setObject:sizeTextField forKey:kSize];
}

- (void)previewAdButtonClicked:(id)sender {
    UISegmentedControl *adServerSegControl = [self.generalSettingsFields objectForKey:kAdServer];
    UISegmentedControl *adTypeSegControl = [self.generalSettingsFields objectForKey:kAdType];
    UITextField *placementIdField = [self.generalSettingsFields objectForKey:kPlacementId];
    UITextField *sizeIdField = [self.generalSettingsFields objectForKey:kSize];

    NSString *adType =[adTypeSegControl titleForSegmentAtIndex:[adTypeSegControl selectedSegmentIndex]];

    NSDictionary *settings = @{kAdServer : [adServerSegControl titleForSegmentAtIndex:[adServerSegControl selectedSegmentIndex]],
                               kPlacementId : [placementIdField text],
                               kSize : [sizeIdField text], kGDPRString :self.consentStorageVC.consentString};

    UIViewController *vcToPush;
    if ([adType isEqualToString:kBanner]) {
        vcToPush = [[BannerTestsViewController alloc] initWithSettings:settings];
    } else if ([adType isEqualToString:kInterstitial]) {
        vcToPush = [[InterstitialTestsViewController alloc] initWithSettings:settings];
    } else if ([adType isEqualToString:kVideo]) {
        vcToPush = [[VideoTestsViewController alloc] init];
    }

    if (vcToPush != nil) {
        vcToPush.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vcToPush animated:NO];
    }
}

- (void)adServerClicked:(id)sender {
    UISegmentedControl *adServerSegControl = (UISegmentedControl *)sender;
    NSString *adServer = [adServerSegControl titleForSegmentAtIndex:[adServerSegControl selectedSegmentIndex]];
    PBPrimaryAdServerType primaryAdServer = PBPrimaryAdServerUnknown;
    if ([adServer isEqualToString:kDFPAdServer]) {
        primaryAdServer = PBPrimaryAdServerDFP;
    } else if ([adServer isEqualToString:kMoPubAdServer]) {
        primaryAdServer = PBPrimaryAdServerMoPub;
    } else if ([adServer isEqualToString:kAdformAdServer]) {
        primaryAdServer = PBPrimaryAdServerAdform;
    }

    [self updateAdTypeSegmentFor:adServer];
    [self setupPrebidAndRegisterAdUnitsWithAdServer:primaryAdServer];
}

- (void)updateAdTypeSegmentFor:(NSString *)adServer {
    UISegmentedControl *adTypeControl = _generalSettingsFields[kAdType];

    if ([adServer isEqualToString:kAdformAdServer] && adTypeControl.numberOfSegments == 2) {
        [adTypeControl removeSegmentAtIndex:1 animated:true];
        adTypeControl.selectedSegmentIndex = 0;
    } else if (adTypeControl.numberOfSegments == 1) {
        [adTypeControl insertSegmentWithTitle:kInterstitial atIndex:1 animated:true];
    }
}

- (BOOL)setupPrebidAndRegisterAdUnitsWithAdServer:(PBPrimaryAdServerType)adServer {
    @try {
        PBBannerAdUnit *__nullable adUnit1 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:kAdUnit1Id andConfigId:kAdUnit1ConfigId];
        PBInterstitialAdUnit *__nullable adUnit2 = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:kAdUnit2Id andConfigId:kAdUnit2ConfigId];
        [adUnit1 addSize:CGSizeMake(300, 250)];
        
        [PrebidMobile shouldLoadOverSecureConnection:YES];

        [PrebidMobile registerAdUnits:@[adUnit1, adUnit2] withAccountId:kAccountId withHost:kPBServerHost andPrimaryAdServer:adServer];

    } @catch (PBException *ex) {
        NSLog(@"%@",[ex reason]);
    } @finally {
        return YES;
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaders.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.generalSettingsData.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if(section == 0){
//        return 40.0f;
//    }
//    else {
//        return 20.0f;
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleTableIdentifier = kAdSettingsTableViewReuseId;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    UIView *rightContentView = [self.generalSettingsFields objectForKey:[self.generalSettingsData objectAtIndex:indexPath.row]];

    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = [self.generalSettingsData objectAtIndex:indexPath.row];
            rightContentView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - rightContentView.frame.size.width - kRightMargin,
                                                (cell.contentView.frame.size.height - rightContentView.frame.size.height) / 2,
                                                rightContentView.frame.size.width,
                                                rightContentView.frame.size.height);
            [cell.contentView addSubview:rightContentView];
            break;
        default:
            break;
    }
    return cell;
}

- (void)didPressNext:(id)sender {
    CMPConsentViewController *consentToolVC = [[CMPConsentViewController alloc] init];
    // Both the Android and iOS versions are implemented as a wrapper around modified Web CMP reference.
    // Instruction on how to install and configure the WebCMP JS reference can be found inside the reference folder of this repo.
    // This example uses a demo page setup using the same instructions.
    consentToolVC.cmpSettings.cmpURL = @"https://acdn.adnxs.com/mobile/democmp/docs/mobilecomplete.html";
    consentToolVC.cmpSettings.subjectToGDPR = @"1";
    consentToolVC.cmpSettings.cmpPresent = YES;
    consentToolVC.delegate = self;
    consentToolVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:consentToolVC animated:YES completion:nil];
}

#pragma mark CMPConsentToolViewController delegate
-(void)consentToolViewController:(CMPConsentViewController *)consentToolViewController didReceiveConsentString:(NSString *)consentString {
    [consentToolViewController dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"GDPR Consent"
                                                                   message:consentString
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              NSLog(@"my text");
                                                              [[PBTargetingParams sharedInstance] setSubjectToGDPR:YES];
                                                                [[PBTargetingParams sharedInstance] setGdprConsentString:consentString];
                                                              self.navigationItem.leftBarButtonItem = nil;
                                                              
                                                          }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)consentToolViewController:(CMPConsentViewController *)consentToolViewController didReceiveURL:(NSURL *)url{
    
    UIApplication *application = [UIApplication sharedApplication];
    if (@available(iOS 10.0, *)) {
        [application openURL:url options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:url];
        
    }
}

@end
