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

#import "SettingsTableViewController.h"
#import "HelpViewController.h"
#import "SegmentCell.h"
#import "LabelAccessoryCell.h"
#import "HeaderCell.h"
#import "IdCell.h"

NSString *__nonnull const kGeneralInfoText = @"General Info";

NSString *__nonnull const kAdServerInfoText = @"AdServer Info";

NSString *__nonnull const kPrebidServerInfoText = @"Prebid Server Info";

NSString *__nonnull const kAdFormatText = @"Ad Format";
NSString *__nonnull const kAdSizeText = @"Ad Size";

NSString *__nonnull const kAdServerLabel = @"Ad Server";
NSString *__nonnull const kAdUnitIdLabel = @"Ad Unit ID";
NSString *__nonnull const kBidPriceLabel = @"Bid Price";

NSString *__nonnull const kPBAccountLabel = @"Account ID";
NSString *__nonnull const kPBConfigLabel = @"Config ID";
NSString *__nonnull const KPBHostLabel = @"Server Host";


@interface SettingsTableViewController ()

@property NSDictionary *tableViewDictionaryItems;
@property NSArray *sectionTitles;
@property NSArray *generalInfoTitles;
@property NSArray *adServerTitles;
@property NSArray *prebidServerTitles;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Doctor Prebid";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(btnAboutPressed:)];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0]];
    
    // remove the scrolling of tableview
    self.tableView.scrollEnabled = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.generalInfoTitles = @[kAdFormatText, kAdSizeText];
    self.adServerTitles = @[kAdServerLabel, kBidPriceLabel, kAdUnitIdLabel];
    self.prebidServerTitles = @[KPBHostLabel, kPBAccountLabel, kPBConfigLabel];
    
    self.tableViewDictionaryItems = @{kGeneralInfoText :self.generalInfoTitles, kAdServerInfoText:self.adServerTitles, kPrebidServerInfoText: self.prebidServerTitles};
    
    self.sectionTitles = @[kGeneralInfoText, kAdServerInfoText, kPrebidServerInfoText];
    
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerCell = @"HeaderCell";
    
    HeaderCell *cell = (HeaderCell *)[tableView dequeueReusableCellWithIdentifier:headerCell];
    
    if(cell != nil){
        NSString *titleText = [self.sectionTitles objectAtIndex:section];
        
        cell.lblHeader.text = titleText;
    }
    return cell;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section != 0){
        return 3;
    }
    
    return 2;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        return 50.0f;
    } else if(indexPath.section == 1){
        if(indexPath.row == 2){
            return 60.0f;
        } else {
            return 50.0f;
        }
    } else if(indexPath.section == 2){
        if(indexPath.row == 0){
            return 50.0f;
        }
    }
    
    return 60.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return [self configureGeneralInfoSection:tableView withIndexPath:indexPath];
    } else if(indexPath.section == 1){
        return [self configureAdServerSection:tableView withIndexPath:indexPath];
    } else if(indexPath.section == 2){
        return [self configurePrebidServerSection:tableView withIndexPath:indexPath];
    }

    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 2)
        return 50.0f;
    else
        return 0.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if(section == 2){
        UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50.0f)];
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setTitle:@"Test Prebid Setup" forState:UIControlStateNormal];
        nextButton.frame = CGRectMake(0.0, 0.0, 250.0, 30.0);
        [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextButton setBackgroundColor:[UIColor colorWithRed:0.23 green:0.53 blue:0.76 alpha:1.0]];
        [nextButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [nextButton addTarget:self action:@selector(didPressNext:) forControlEvents:UIControlEventTouchUpInside];
        nextButton.clipsToBounds = YES;
        [footerView addSubview:nextButton];
        nextButton.center = footerView.center;
        return footerView;
    } else
    {
        return nil;
    }
}

- (UITableViewCell *) configureGeneralInfoSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        static NSString *segmentCell = @"SegmentCell";
        
        SegmentCell *cell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:segmentCell];
        
        if(cell != nil){
            cell.labelText.text = kAdFormatText;
            NSArray *adFormatItems = @[@"Banner", @"Interstitial"];
            [cell.segmentControl setTitle:adFormatItems[0] forSegmentAtIndex:0];
            [cell.segmentControl setTitle:adFormatItems[1] forSegmentAtIndex:1];
        }
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *labelAccessoryCell = @"LabelAccessoryCell";
        
        LabelAccessoryCell *cell = (LabelAccessoryCell *)[tableView dequeueReusableCellWithIdentifier:labelAccessoryCell];
        
        if(cell != nil){
            cell.lblTitle.text = kAdSizeText;
            cell.lblSelectedContent.enabled = NO;
            cell.lblSelectedContent.text = @"300x250";
            cell.lblSelectedContent.textColor = [UIColor darkGrayColor];
            
        }
        return cell;
    }
    
    return nil;
}

- (UITableViewCell *) configureAdServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        static NSString *segmentCell = @"SegmentCell";
        
        SegmentCell *cell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:segmentCell];
        
        if(cell != nil){
            cell.labelText.text = kAdServerLabel;
            NSArray *adServerItems = @[@"DFP", @"MoPub"];
            [cell.segmentControl setTitle:adServerItems[0] forSegmentAtIndex:0];
            [cell.segmentControl setTitle:adServerItems[1] forSegmentAtIndex:1];
        }
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *labelAccessoryCell = @"LabelAccessoryCell";
        
        LabelAccessoryCell *cell = (LabelAccessoryCell *)[tableView dequeueReusableCellWithIdentifier:labelAccessoryCell];
        
        if(cell != nil){
            cell.lblTitle.text = kBidPriceLabel;
            cell.lblSelectedContent.text = @"$0.00";
            cell.lblSelectedContent.borderStyle = UITextBorderStyleRoundedRect;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        return cell;
    }
    else if (indexPath.row == 2){
        static NSString *idCell = @"IdCell";
        
         IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kAdUnitIdLabel;
        }
        return cell;
    }
    
    return nil;
}

- (UITableViewCell *) configurePrebidServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        static NSString *segmentCell = @"SegmentCell";
        
        SegmentCell *cell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:segmentCell];
        
        if(cell != nil){
            cell.labelText.text = KPBHostLabel;
            NSArray *adServerItems = @[@"AppNexus", @"Rubicon"];
            [cell.segmentControl setTitle:adServerItems[0] forSegmentAtIndex:0];
            [cell.segmentControl setTitle:adServerItems[1] forSegmentAtIndex:1];
        }
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kPBAccountLabel;
        }
        return cell;
    }
    else if (indexPath.row == 2){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kPBConfigLabel;
        }
        return cell;
    }
    
    return nil;
}

#pragma mark - Actions

-(void) btnAboutPressed :(id)sender {
    HelpViewController *helpController = [[HelpViewController alloc] init];
    
    [self.navigationController pushViewController:helpController animated:NO];
    
}

@end
