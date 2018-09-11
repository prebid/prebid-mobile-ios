//
//  DemandViewController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/6/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "DemandViewController.h"
#import "DemandHeaderCell.h"
#import "DemandViewCell.h"
#import "RRViewController.h"

NSString *__nonnull const cellString = @"demandCell";
//NSString *__nonnull const headerString = @"demandHeader";

@interface DemandViewController ()<UITableViewDataSource, UITableViewDelegate>

@property NSDictionary *dictBidders;

@end

@implementation DemandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DemandViewCell" bundle:nil] forCellReuseIdentifier:cellString];
   
    
    id content = [self.resultsDictionary objectForKey:@"bidders"];
    
    if([content isKindOfClass:[NSDictionary class] ]){
        self.dictBidders = (NSDictionary *) content;
    }
    
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"Real-Time Demand";
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.title = @"Bids";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dictBidders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerCell = @"headerSection";
    
    DemandHeaderCell *cell = (DemandHeaderCell *)[tableView dequeueReusableCellWithIdentifier:headerCell];
    
    if(cell == nil)
        return nil;
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    cell.lblLeftHeader.text = [self.dictBidders.allKeys[section] capitalizedString];
    cell.lblRightHeader.text = @"Request & Response";
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 120.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 46.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemandViewCell *cell = (DemandViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellString];
    
    if(cell == nil)
        return nil;
    
    NSArray *allValues = [self.dictBidders allValues];
    
    NSDictionary *adServerContent = [allValues objectAtIndex:indexPath.section];
    
    int validBid = [[adServerContent objectForKey:@"bid"] intValue];
    int noBid = [[adServerContent objectForKey:@"nobid"] intValue];
    int timeout = [[adServerContent objectForKey:@"timeout"] intValue];
    double cpm = [[adServerContent objectForKey:@"cpm"] doubleValue];;
    int error = [[adServerContent objectForKey:@"error"] intValue];
    
    cell.lblAvgCPM.text = [NSString stringWithFormat:@"$%.02f", cpm];
    cell.lblErrorRate.text = [NSString stringWithFormat:@"%d", error];
    cell.lblNoBidRate.text = [NSString stringWithFormat:@"%d", noBid];
    cell.lblValidBidRate.text = [NSString stringWithFormat:@"%d", validBid];
    cell.lblTimeoutRate.text = [NSString stringWithFormat:@"%d", timeout];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    RRViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"rrController"];
    
    controller.requestContent = [self.resultsDictionary objectForKey:@"request"];
    
    NSArray *allValues = [self.dictBidders allValues];
    NSDictionary *adServerContent = [allValues objectAtIndex:indexPath.section];
    
    NSString *validBid = [adServerContent objectForKey:@"serverResponse"];
    
    controller.responseContent = validBid;
    
    controller.titleString = [self.dictBidders.allKeys[indexPath.section] capitalizedString];
    
    
    [self.navigationController pushViewController:controller animated:YES];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
