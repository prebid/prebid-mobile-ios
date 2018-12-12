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

#import "DemandViewController.h"
#import "DemandHeaderCell.h"
#import "DemandViewCell.h"
#import "RRViewController.h"

NSString *__nonnull const cellString = @"demandCell";

@interface DemandViewController ()<UITableViewDataSource, UITableViewDelegate, DemandHeaderCellDelegate>

@property NSDictionary *dictBidders;

@end

@implementation DemandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"Real-Time Demand";
    NSNumber *status = [self.resultsDictionary objectForKey:@"responseStatus"];
    if (status == [NSNumber numberWithInteger:200]) {
        id content = [self.resultsDictionary objectForKey:@"bidders"];
        
        if([content isKindOfClass:[NSDictionary class] ]){
            self.dictBidders = (NSDictionary *) content;
        }
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        
        [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"DemandViewCell" bundle:nil] forCellReuseIdentifier:cellString];
        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footer;
    } else {
        for (UIView * view in self.view.subviews) {
            [view removeFromSuperview];
        }
        UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
        textView.text = [self.resultsDictionary objectForKey:@"error"];
        [textView setFont:[UIFont systemFontOfSize:14.0]];
        [self.view addSubview:textView];
    }

    
    // Do any additional setup after loading the view.
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
    
    cell.lblLeftHeader.text = [self.dictBidders.allKeys[section] capitalizedString];
    cell.lblRightHeader.text = @"Request & Response";
    [cell.btnDetail setTag:section];
    cell.delegate = self;
    
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
    
    NSArray *allValues = [self.dictBidders allValues];
    
    NSDictionary *adServerContent = [allValues objectAtIndex:indexPath.section];
    
    int validBid = [[adServerContent objectForKey:@"bid"] intValue];
    int noBid = [[adServerContent objectForKey:@"nobid"] intValue];
    int timeout = [[adServerContent objectForKey:@"timeout"] intValue];
    
    
    
    double cpm = [[adServerContent objectForKey:@"cpm"] doubleValue];
    
    if(!isnan(cpm)){
        cell.lblAvgCPM.text = [NSString stringWithFormat:@"$%.02f", cpm];
        
    } else {
        cell.lblAvgCPM.text = @"$0.00";
    }
    
    int error = [[adServerContent objectForKey:@"error"] intValue];
    
    
    cell.lblErrorRate.text = [NSString stringWithFormat:@"%d%%", error];
    cell.lblNoBidRate.text = [NSString stringWithFormat:@"%d%%", noBid];
    cell.lblValidBidRate.text = [NSString stringWithFormat:@"%d%%", validBid];
    cell.lblTimeoutRate.text = [NSString stringWithFormat:@"%d%%", timeout];
    
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

-(void) didSelectUserHeaderTableViewCell:(BOOL)isSelected UserHeader:(id)headerCell{
    
    if([headerCell isKindOfClass:[DemandHeaderCell class]]){
        DemandHeaderCell *dHeaderCell = (DemandHeaderCell *) headerCell;
        
        NSInteger section = (long)dHeaderCell.btnDetail.tag;
       
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        RRViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"rrController"];
        
        controller.requestContent = [self.resultsDictionary objectForKey:@"request"];
        
        NSArray *allValues = [self.dictBidders allValues];
        NSDictionary *adServerContent = [allValues objectAtIndex:section];
        
        NSString *validBid = [adServerContent objectForKey:@"serverResponse"];
        
        controller.responseContent = validBid;
        
        controller.titleString = [self.dictBidders.allKeys[section] capitalizedString];
        
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
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
