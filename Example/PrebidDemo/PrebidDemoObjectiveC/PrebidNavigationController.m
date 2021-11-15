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

@interface PrebidNavigationController ()

@property (nonatomic, strong) NSArray *adServerList;
@property (nonatomic, strong) NSArray *adUnitList;

@end

@implementation PrebidNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Prebid Demo";
    
    self.title = @"Prebid Demo";
    
    self.adServerList = @[@"DFP", @"MoPub", @"In-App", @"Rendering GAM", @"Rendering MoPub"];
    self.adUnitList = @[@"Banner", @"Interstitial", @"InAppNative"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.adServerList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.adUnitList.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.adServerList objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *adUnit = [self.adUnitList objectAtIndex:indexPath.row];
    cell.textLabel.text = adUnit;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    if (indexPath.section < 2) {
        ViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];
        viewController.adServer = [self.adServerList objectAtIndex:indexPath.section];
        viewController.adUnit = [self.adUnitList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_InApp;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (indexPath.row == 1) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_InApp;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_RenderingGAM;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (indexPath.row == 1) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingGAM;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            RenderingBannerViewController * viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingBannerVC"];
            viewController.integrationKind = IntegrationKind_RenderingMoPub;
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (indexPath.row == 1) {
            RenderingInterstitialViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RenderingInterstitialVC"];
            viewController.integrationKind = IntegrationKind_RenderingMoPub;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}
@end
