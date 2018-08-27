//
//  TestSummaryViewController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 8/13/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "TestSummaryViewController.h"
#import "SectionCell.h"
#import "TestHeaderCell.h"
#import "PBVLineItemsSetupValidator.h"
#import "CPMSectionCell.h"
#import "KVViewController.h"
#import "AdServerResponseViewController.h"

NSString *__nonnull const kAdServerTestHeader = @"Ad Server Setup Validation";
NSString *__nonnull const kAdServerRequestSentWithKV = @"Ad server request sent with key-value targeting";
NSString *__nonnull const kpbmjssent = @"Prebid Mobile creative HTML served";

NSString *__nonnull const kRealTimeHeader = @"Real-Time Demand Validation";
NSString *__nonnull const kBidRequestSent = @"100 bid requests sent";
NSString *__nonnull const kBidResponseReceived = @"bid response received";
NSString *__nonnull const kCPMReceived = @"CPM response time";

NSString *__nonnull const kSDKHeader = @"End-to-End Prebid Mobile SDK Validation";

NSString *__nonnull const kSectionCellString = @"sCell";
NSString *__nonnull const kHeaderCellString = @"headerCell";

@interface TestSummaryViewController ()<PBVLineItemsSetupValidatorDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSDictionary *tableViewDictionaryItems;
@property NSArray *sectionTitles;
@property NSArray *adServerTitles;
@property NSArray *demandTitles;

@property NSIndexPath *selectedIndex;

@property PBVLineItemsSetupValidator *validator1;

@property Boolean adServerTestPassed;
@property Boolean isKVSuccess;
@property Boolean isPBMReceived;

@property NSDictionary *lineItemTestKeywords;

@end

@implementation TestSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Test Summary";
    
    self.adServerTitles = @[kAdServerRequestSentWithKV, kpbmjssent];
    self.demandTitles = @[kBidRequestSent, kBidResponseReceived, kCPMReceived];
    
    self.tableViewDictionaryItems = @{kAdServerTestHeader :self.adServerTitles, kRealTimeHeader:self.demandTitles};
    
    self.sectionTitles = @[kAdServerTestHeader, kRealTimeHeader, kSDKHeader];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"SectionCell" bundle:nil] forCellReuseIdentifier:kSectionCellString];
     [self.tableView registerNib:[UINib nibWithNibName:@"TestHeaderCell" bundle:nil] forCellReuseIdentifier:kHeaderCellString];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CPMSectionCell" bundle:nil] forCellReuseIdentifier:@"cpmCell"];
    
    self.adServerTestPassed = NO;
    self.isKVSuccess = NO;
    self.isPBMReceived = NO;
    
    [self startAdServerValidation];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) return 2;
    if(section == 2)
        return 5;
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TestHeaderCell *cell = (TestHeaderCell *)[tableView dequeueReusableCellWithIdentifier:kHeaderCellString];
    
    if(cell == nil)
        return nil;
    
    if(section == 0){
        if(self.adServerTestPassed)
            cell.imgStatus.image = [UIImage imageNamed:@"SuccessLarge"];
        else
            cell.imgStatus.image = [UIImage imageNamed:@"FailureLarge"];
    } else {
        cell.imgStatus.image = [UIImage imageNamed:@"SuccessLarge"];
    }
    if(cell != nil){
        NSString *titleText = [self.sectionTitles objectAtIndex:section];
        
        cell.lblHeader1.text = titleText;
        cell.lblHeader2.text = @"Passed";
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    //[self btnAboutPressed:self];
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1 && indexPath.row == 2){
        return 75.0f;
    } else if (indexPath.section == 2 && indexPath.row == 4){
        return 75.0f;
    }
    return 40.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 61.0f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        KVViewController * kvController = [storyboard instantiateViewControllerWithIdentifier:@"kvController"];
        kvController.keyWordsDictionary = self.lineItemTestKeywords ;
        [self.navigationController pushViewController:kvController animated:YES];
      
    } else if (indexPath.section == 0 && indexPath.row == 1){
        AdServerResponseViewController *controller = [[AdServerResponseViewController alloc] initWithValidator:self.validator1];
         [self.navigationController pushViewController:controller animated:YES];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return [self configureAdServerSection:self.tableView withIndexPath:indexPath];
    } else if(indexPath.section == 1){
        return [self configureDemandServerSection:self.tableView withIndexPath:indexPath];
    } else if (indexPath.section == 2){
        return [self configurePrebidMobileSDKSection:self.tableView withIndexPath:indexPath];
    }
    
    return nil;
}

-(UITableViewCell *) configureAdServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    SectionCell *cell = (SectionCell *)[self.tableView dequeueReusableCellWithIdentifier:kSectionCellString ];

    if(cell == nil)
        return nil;
    
    cell.imageView.image = [UIImage imageNamed:@"FailureSmall"];
    
    if (indexPath.row == 0){
        
       cell.lblHeader.text = kAdServerRequestSentWithKV;
        
        if(self.isKVSuccess){
          cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        }
       
    } else if(indexPath.row == 1){
        
        if(self.isPBMReceived){
            cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        }
        cell.lblHeader.text = kpbmjssent;
       
    }
    return cell;
}

-(UITableViewCell *) configureDemandServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    SectionCell *cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:kSectionCellString];
    
   if(cell == nil)
       return nil;
    
    cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
    if (indexPath.row == 0){
        
        cell.lblHeader.text = kBidRequestSent;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
        
    } else if(indexPath.row == 1){
        cell.lblHeader.text = kBidResponseReceived;
        return cell;
        
    } else if(indexPath.row == 2){
        
        CPMSectionCell *cpmCell = (CPMSectionCell *)[tableView dequeueReusableCellWithIdentifier:@"cpmCell"];
        
        cpmCell.lblHeader.text = kCPMReceived;
        
        cpmCell.lblHeader2.text = @"";
        
        return cpmCell;
        
    }
    
    return nil;
}

-(UITableViewCell *) configurePrebidMobileSDKSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    SectionCell *cell = (SectionCell *)[self.tableView dequeueReusableCellWithIdentifier:kSectionCellString ];
    
    if(cell == nil)
        return nil;
    
    cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
    
    if (indexPath.row == 0){
        
        cell.lblHeader.text = kBidRequestSent;
        
    } else if(indexPath.row == 1){
        cell.lblHeader.text = kBidResponseReceived;
        
    } else if (indexPath.row == 2){
        
        cell.lblHeader.text = kAdServerRequestSentWithKV;
        
        cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        
        
    } else if(indexPath.row == 3){
        
        cell.lblHeader.text = kAdServerRequestSentWithKV;
        
    } else if(indexPath.row == 4){
        
        cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        
        cell.lblHeader.text = kpbmjssent;
        
    }
    return cell;

}

- (void)startAdServerValidation{
    self.validator1 = [[PBVLineItemsSetupValidator alloc] init];
    self.validator1.delegate = self;
    [self.validator1 startTest];
}

#pragma mark AdServerValidation PBVLineItemsSetupValidatorDelegate
- (void)setKeywordsSuccessfully:(NSDictionary *)keywords
{
    self.lineItemTestKeywords = keywords;
    self.isKVSuccess = YES;
    [self.tableView reloadData];
    
}
- (void)adServerDidNotRespondWithPrebidCreative
{
    self.isPBMReceived = NO;
    self.adServerTestPassed = NO;
    [self.tableView reloadData];
}

-(void)adServerRespondedWithPrebidCreative
{
    self.isPBMReceived = YES;
    self.adServerTestPassed = YES;
    [self.tableView reloadData];
}


@end
