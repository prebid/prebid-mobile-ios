//
//  LineItemsTabController.m
//  PrebidMobileValidator
//
//  Created by Punnaghai Puviarasu on 4/5/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "LineItemsTabController.h"
#import "LineItemsViewController.h"
#import "LineItemAdsViewController.h"
#import "LogsViewController.h"

NSString *__nonnull const kTitleText = @"AdServer Setup Validator";

@interface LineItemsTabController ()


@end

@implementation LineItemsTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = kTitleText;
    
    // Do any additional setup after loading the view.
    LineItemsViewController *lineItemsController = [[LineItemsViewController alloc] init];
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:0];
    
    lineItemsController.tabBarItem = item1;
    
    LineItemAdsViewController *lineItemsAdController = [[LineItemAdsViewController alloc] init];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"Ads" image:nil tag:1];
    
    lineItemsAdController.tabBarItem = item2;
    
    LogsViewController *logsViewController = [[LogsViewController alloc] init];
    
    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"Logs" image:nil tag:2];
    
    logsViewController.tabBarItem = item3;
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:lineItemsController];
    [tabViewControllers addObject:lineItemsAdController];
    [tabViewControllers addObject:logsViewController];
    
    [self setViewControllers: tabViewControllers];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
