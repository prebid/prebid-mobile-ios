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

#import "ListViewController.h"
#import "LineItemAdsViewController.h"
#import "PBVTableViewCell.h"
#import "PBVSharedConstants.h"
#import "PBVPrebidServerConfigViewController.h"
#import "PBVPBSRequestResponseValidator.h"
#import "PBVPrebidSDKValidator.h"
#import "PBVLineItemsSetupValidator.h"

#define CellReuseID @"ReuseCell"

@interface ListViewController ()<PBVPrebidSDKValidatorDelegate, PBVLineItemsSetupValidatorDelegate>

@property (strong, nonatomic) NSArray *items;
@property PBVLineItemsSetupValidator *validator1;
@property PBVPBSRequestResponseValidator *validator2;
@property PBVPrebidSDKValidator *validator3;
@property UIRefreshControl *refreshControll;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Prebid Validator";
    self.items = [[NSArray alloc] initWithObjects:@"AdServer Setup Validation", @"PrebidServer Configuration Validation",@"PrebidSDK Validation", nil];
    
    
    UITableView *tableView = (UITableView *)self.view;
    [tableView registerNib:[UINib nibWithNibName:@"PBVTableViewCell" bundle:nil] forCellReuseIdentifier:CellReuseID];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _refreshControll = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:_refreshControll];
    [_refreshControll addTarget:self action:@selector(refreshTests) forControlEvents:UIControlEventValueChanged];
    [self startTests];
}

-(void)refreshTests
{
    [_refreshControll endRefreshing];
    [self startTests];
}

- (void)startTests{
    // set all cells to be in progress
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *test1 = [NSIndexPath indexPathForRow:0 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test1];
        cell.progressImage.image = [UIImage imageNamed:@"Progress"];
        NSIndexPath *test2 = [NSIndexPath indexPathForRow:1 inSection:0] ;
        cell = [(UITableView *) self.view cellForRowAtIndexPath:test2];
        cell.progressImage.image = [UIImage imageNamed:@"Progress"];
        NSIndexPath *test3 = [NSIndexPath indexPathForRow:2 inSection:0] ;
        cell = [(UITableView *) self.view cellForRowAtIndexPath:test3];
        cell.progressImage.image = [UIImage imageNamed:@"Progress"];
    });
    _validator1 = [[PBVLineItemsSetupValidator alloc] init];
    _validator1.delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(runTestForValidator1) userInfo:nil repeats:NO];
    _validator2 = [[PBVPBSRequestResponseValidator alloc] init];
    [_validator2 startTestWithCompletionHandler:^(Boolean result) {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *test2 = [NSIndexPath indexPathForRow:1 inSection:0] ;
                PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test2];
                cell.progressImage.image = [UIImage imageNamed:@"Green"];
            });
   
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                // add red icon to this app
                 NSIndexPath *test2 = [NSIndexPath indexPathForRow:1 inSection:0] ;
                PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test2];
                cell.progressImage.image = [UIImage imageNamed:@"Red"];
            });
        }
    }];
    _validator3 = [[PBVPrebidSDKValidator alloc] init];
    _validator3.delegate = self;
    [_validator3 startTest];
}

-(void) runTestForValidator1
{
    [_validator1 startTest];
}
#pragma mark LineItems test delegate
- (void)lineItemsWereNotSetupProperly
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *test1 = [NSIndexPath indexPathForRow:0 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test1];
        cell.progressImage.image = [UIImage imageNamed:@"Red"];
    });
}

-(void)lineItemsWereSetupProperly
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *test1 = [NSIndexPath indexPathForRow:0 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test1];
        cell.progressImage.image = [UIImage imageNamed:@"Green"];
    });
}

#pragma mark SDK integration test delegate
- (void)sdkIntegrationDidPass
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *test3 = [NSIndexPath indexPathForRow:2 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test3];
        cell.progressImage.image = [UIImage imageNamed:@"Green"];
    });
}

- (void)sdkIntegrationDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *test3 = [NSIndexPath indexPathForRow:2 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test3];
        cell.progressImage.image = [UIImage imageNamed:@"Red"];
    });
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
    
    cell.progressImage.image = [UIImage imageNamed:@"Progress"];
    
    cell.lblValidator.text=item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0){
        LineItemAdsViewController *lineItemsAdsViewController =
        [[LineItemAdsViewController alloc] initWithValidator:_validator1];
        [self.navigationController pushViewController:lineItemsAdsViewController animated:YES];
    } if(indexPath.row == 2){
        UIViewController *controller = [_validator3 getViewController];
    
        [self.navigationController pushViewController:controller animated:YES];
    } if(indexPath.row == 1){
        PBVPrebidServerConfigViewController *pbServerConfigController =
        [[PBVPrebidServerConfigViewController alloc]initWithValidator:_validator2];
        [self.navigationController pushViewController:pbServerConfigController animated:YES];
    }
}

@end
