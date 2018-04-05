//
//  ListViewController.m
//  PrebidTestApp
//
//  Created by Punnaghai Puviarasu on 4/3/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "ListViewController.h"
#import "LineItemsTabController.h"
#import "SettingsViewController.h"

@interface ListViewController ()

@property (strong, nonatomic) NSArray *items;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Prebid Testing Tool";
    
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.items = [[NSArray alloc] initWithObjects:@"AdServer Setup Validation",@"PrebidSDK Testing", @"AppNexus Settings Validation", @"PrebidServer Configuration Validation", nil];
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
    
    static NSString *CellIdentifier = @"Cell Identifier";
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *item = [self.items objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0){
        LineItemsTabController *lineItemsTabController = [[LineItemsTabController alloc] init];
        
        [self.navigationController pushViewController:lineItemsTabController animated:YES];
    } if(indexPath.row == 1){
        SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
        
        [self.navigationController pushViewController:settingsViewController animated:YES];
    }
}


#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//    if ([segue.destinationViewController isKindOfClass:[TSPBooksViewController class]]) {
//        // Configure Books View Controller
//        [(TSPBooksViewController *)segue.destinationViewController];
//
//    }
//}


@end
