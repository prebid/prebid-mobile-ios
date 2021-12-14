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

#import "PrebidNavigationController.h"
#import "ViewController.h"
#import "RenderingBannerViewController.h"
#import "RenderingInterstitialViewController.h"
#import "IntegrationKindUtilites.h"
#import "RenderingRewardedViewController.h"

@interface PrebidNavigationController ()

@property (nonatomic, strong) NSArray *integrationsList;
@property (nonatomic, strong) NSDictionary *integrationsDescr;

@end

@implementation PrebidNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Prebid Demo";
    
    self.title = @"Prebid Demo";
    
    self.integrationsList = [IntegrationKindUtilites IntegrationKindAllCases];
    self.integrationsDescr = [IntegrationKindUtilites IntegrationKindDescr];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.integrationsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [IntegrationKindUtilites isRenderingIntegrationKind:section] ?
    [IntegrationKindUtilites IntegrationAdFormatRendering].count :
    [IntegrationKindUtilites IntegrationAdFormatOriginal].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.integrationsDescr[self.integrationsList[section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *adFormats = [IntegrationKindUtilites IntegrationAdFormatFor:indexPath.section];
    IntegrationAdFormat adFormat = [adFormats[indexPath.row] intValue];
    NSDictionary *descr = [IntegrationKindUtilites IntegrationAdFormatDescr];
    
    NSString *adUnit = descr[[NSNumber numberWithInteger:adFormat]];
    cell.textLabel.text = adUnit;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    if (indexPath.section == IntegrationKind_OriginalGAM || indexPath.section == IntegrationKind_OriginalMoPub || indexPath.section == IntegrationKind_OriginalAdMob) {
        ViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];
        NSNumber *num = (NSNumber *) self.integrationsList[indexPath.section];
        viewController.adServer = (IntegrationKind) [num intValue];
        viewController.adUnit = (IntegrationAdFormat) [IntegrationKindUtilites.IntegrationAdFormatOriginal[indexPath.row] intValue];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == IntegrationKind_InApp) {
        IntegrationAdFormat integrationAdFormat = [IntegrationKindUtilites.IntegrationAdFormatRendering[indexPath.row] intValue];
        if (integrationAdFormat == IntegrationAdFormat_Banner) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_InApp;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Interstitial) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_InApp;
            viewController.integrationAdFormat = IntegrationAdFormat_Interstitial;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_InApp;
            viewController.integrationAdFormat = IntegrationAdFormat_InterstitialVideo;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Rewarded) {
            RenderingRewardedViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingRewardedVC"];
            viewController.integrationKind = IntegrationKind_InApp;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == IntegrationKind_RenderingGAM) {
        IntegrationAdFormat integrationAdFormat = [IntegrationKindUtilites.IntegrationAdFormatRendering[indexPath.row] intValue];
        if (integrationAdFormat == IntegrationAdFormat_Banner) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_RenderingGAM;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Interstitial) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingGAM;
            viewController.integrationAdFormat = IntegrationAdFormat_Interstitial;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingGAM;
            viewController.integrationAdFormat = IntegrationAdFormat_InterstitialVideo;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Rewarded) {
            RenderingRewardedViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingRewardedVC"];
            viewController.integrationKind = IntegrationKind_RenderingGAM;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == IntegrationKind_RenderingMoPub) {
        IntegrationAdFormat integrationAdFormat = [IntegrationKindUtilites.IntegrationAdFormatRendering[indexPath.row] intValue];
        if (integrationAdFormat == IntegrationAdFormat_Banner) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_RenderingMoPub;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Interstitial) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingMoPub;
            viewController.integrationAdFormat = IntegrationAdFormat_Interstitial;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingMoPub;
            viewController.integrationAdFormat = IntegrationAdFormat_InterstitialVideo;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Rewarded) {
            RenderingRewardedViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingRewardedVC"];
            viewController.integrationKind = IntegrationKind_RenderingMoPub;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == IntegrationKind_RenderingAdMob) {
        IntegrationAdFormat integrationAdFormat = [IntegrationKindUtilites.IntegrationAdFormatRendering[indexPath.row] intValue];
        if (integrationAdFormat == IntegrationAdFormat_Banner) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_RenderingAdMob;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Interstitial) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingAdMob;
            viewController.integrationAdFormat = IntegrationAdFormat_Interstitial;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_InterstitialVideo) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingAdMob;
            viewController.integrationAdFormat = IntegrationAdFormat_InterstitialVideo;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (integrationAdFormat == IntegrationAdFormat_Rewarded) {
            RenderingRewardedViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingRewardedVC"];
            viewController.integrationKind = IntegrationKind_RenderingAdMob;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}
@end
