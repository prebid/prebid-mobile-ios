//
//  ListViewController.m
//  PrebidTestApp
//
//  Created by Punnaghai Puviarasu on 4/3/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "ListViewController.h"
#import "LineItemsTabController.h"
#import "PBVTableViewCell.h"
#import "PBVSharedConstants.h"
#import "PBVPrebidServerConfigViewController.h"
#import "PBVPBSRequestResponseValidator.h"
#import "PBVPrebidSDKValidator.h"

#define CellReuseID @"ReuseCell"

@interface ListViewController ()<PBVPrebidSDKValidatorDelegate>

@property (strong, nonatomic) NSArray *items;

@property PBVPBSRequestResponseValidator *validator2;
@property PBVPrebidSDKValidator *validator3;
@property UIRefreshControl *refreshControll;
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
     _refreshControll = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:_refreshControll];
    [_refreshControll addTarget:self action:@selector(refreshTests) forControlEvents:UIControlEventValueChanged];
    [self startTests];
    // TODO: wei to add validator mode for first test.
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateCell) userInfo:nil repeats:NO];
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

- (void)sdkIntegrationDidPass
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *test3 = [NSIndexPath indexPathForRow:2 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test3];
        cell.progressImage.image = [UIImage imageNamed:@"Green"];
    });
}

-(void) updateCell{
dispatch_async(dispatch_get_main_queue(), ^{
    NSIndexPath *test1 = [NSIndexPath indexPathForRow:0 inSection:0] ;
    PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test1];
    cell.progressImage.image = [UIImage imageNamed:@"Green"];
});
    
}

- (void)sdkIntegrationDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // add red icon to this app
        NSIndexPath *test3 = [NSIndexPath indexPathForRow:2 inSection:0] ;
        PBVTableViewCell *cell = [(UITableView *) self.view cellForRowAtIndexPath:test3];
        cell.progressImage.image = [UIImage imageNamed:@"Red"];
    });
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
    
    cell.progressImage.image = [UIImage imageNamed:@"Progress"];
    
    cell.lblValidator.text=item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0){
        LineItemsTabController *lineItemsTabController = [[LineItemsTabController alloc] init];
        
        [self.navigationController pushViewController:lineItemsTabController animated:YES];
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
