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
#import "DemandValidator.h"
#import "DemandViewController.h"
#import "HelpViewController.h"
#import "PBVSharedConstants.h"


NSString *__nonnull const kSectionCellString = @"sCell";
NSString *__nonnull const kHeaderCellString = @"headerCell";

@interface TestSummaryViewController ()<PBVLineItemsSetupValidatorDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSDictionary *tableViewDictionaryItems;
@property NSArray *sectionTitles;
@property NSArray *adServerTitles;
@property NSArray *demandTitles;

@property NSIndexPath *selectedIndex;

@property UIActivityIndicatorView *indicatorView;

// Adding a state for each test
// state 0 means loading, state 1 means pass, state 2 means failure

@property PBVLineItemsSetupValidator *validator1;
@property int adServerValidationState;
@property int adServerValidationKeyValueState;
@property int adServerValidationPBMCreativeState;

@property DemandValidator *validator2;
@property int demandValidationState;
@property int demandValidationBidRequestSentState;
@property int demandValidataionBidResponseReceivedState;
@end

@implementation TestSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Summary";
    
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
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;

    [self startAdServerValidation];
    [self startDemandValidation];
    
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
    cell.accessoryType = UIButtonTypeDetailDisclosure;
    if(section == 0){
        if(self.adServerValidationState == 1) {
            cell.imgStatus.image = [UIImage imageNamed:@"SuccessLarge"];
        } else if (self.adServerValidationState == 2) {
            cell.imgStatus.image = [UIImage imageNamed:@"FailureLarge"];
        } else {
             cell.imgStatus.image = nil;
        }

    } else {
        cell.imgStatus.image = [UIImage imageNamed:@"SuccessLarge"];
    }
    if(cell != nil){
        NSString *titleText = [self.sectionTitles objectAtIndex:section];
        
        cell.lblHeader1.text = titleText;
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [self btnAboutPressed:self];
}

- (void) btnAboutPressed :(id) sender
{
    HelpViewController *controller = nil;
    if ([sender isKindOfClass:[TestSummaryViewController class] ]) {
        if (self.selectedIndex.section == 0) {
            controller = [[HelpViewController alloc] initWithTitle:kAdServerTestHeader];
        } else if (self.selectedIndex.section == 1) {
            controller = [[HelpViewController alloc] initWithTitle:kRealTimeHeader];
        } else {
            controller = [[HelpViewController alloc] initWithTitle:kSDKHeader];
        }
    }
    if (controller != nil) {
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1 && indexPath.row == 2){
        return 75.0f;
    } else if (indexPath.section == 0 && indexPath.row == 0){
        return 61.0f;
    }
    return 40.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 61.0f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        KVViewController * kvController = [[KVViewController alloc] initWithRequestString:[self.validator1 getAdServerRequest]];
        [self.navigationController pushViewController:kvController animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 1){
        AdServerResponseViewController *controller = [[AdServerResponseViewController alloc] initWithValidator:self.validator1];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        if (self.demandValidationState >0) {
            
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            DemandViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"demandController"];
            
            //DemandValidatorViewController *controller = [[DemandValidatorViewController alloc] init];
            controller.resultsDictionary = self.validator2.testResults;
            //DemandValidatorViewController *controller = [[DemandValidatorViewController alloc] initWithValidator:self.validator2];
            [self.navigationController pushViewController:controller animated:YES];
        }
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
    
    if (indexPath.row == 0){
        cell.lblHeader.numberOfLines = 0;
       cell.lblHeader.text = kAdServerRequestSentWithKV;
        
        if(self.adServerValidationKeyValueState == 1){
            cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        } else if (self.adServerValidationKeyValueState == 2) {
            cell.imageView.image = [UIImage imageNamed:@"FailureSmall"];
        } else {
            cell.imageView.image = nil;
        }
       
    } else if(indexPath.row == 1){
        
        if(self.adServerValidationPBMCreativeState == 1){
            cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        } else if (self.adServerValidationPBMCreativeState == 2) {
            cell.imageView.image = [UIImage imageNamed:@"FailureSmall"];
        } else {
            cell.imageView.image = nil;
        }
        cell.lblHeader.text = kpbmjssent;
       
    }
    return cell;
}

-(UITableViewCell *) configureDemandServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    SectionCell *cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:kSectionCellString];
    
   if(cell == nil)
       return nil;
    
 
    if (indexPath.row == 0){
        
        cell.lblHeader.text = kBidRequestSent;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.demandValidationBidRequestSentState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        } else if (self.demandValidationBidRequestSentState == 2){ // it should never equal to 2
            cell.imageView.image = [UIImage imageNamed:@"FailureSmall"];
        } else {
            cell.imageView.image = nil;
        }
        return cell;
        
    } else if(indexPath.row == 1){
        if (self.demandValidataionBidResponseReceivedState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"SuccessSmall"];
        } else if (self.demandValidataionBidResponseReceivedState == 2) {
            cell.imageView.image = [UIImage imageNamed:@"FailureSmall"];
        } else {
            cell.imageView.image = nil;
        }
        NSNumber *totalBids = [self.validator2.testResults objectForKey:@"totalBids"];
        if (totalBids != nil) {
            cell.lblHeader.text = [NSString stringWithFormat:@"%d bid responses received", [totalBids intValue] ];
        } else {
            cell.lblHeader.text = kBidResponseReceived;
        }
        return cell;
        
    } else if(indexPath.row == 2){
        
        CPMSectionCell *cpmCell = (CPMSectionCell *)[tableView dequeueReusableCellWithIdentifier:@"cpmCell"];
        cpmCell.lblHeader.text = @"$0.00 avg CPM";
        if (self.demandValidationState >0) {
            cpmCell.lblHeader.text = [NSString stringWithFormat:@"$%f avg CPM",[[self.validator2.testResults objectForKey:@"avgCPM"] doubleValue]] ;
            
            cpmCell.lblHeader2.text = @"";
        }

        
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
    self.adServerValidationState = 0;
    self.adServerValidationKeyValueState = 0;
    self.adServerValidationPBMCreativeState = 0;
    self.validator1 = [[PBVLineItemsSetupValidator alloc] init];
    self.validator1.delegate = self;
    [self.validator1 startTest];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark AdServerValidation PBVLineItemsSetupValidatorDelegate

- (void)didFindPrebidKeywordsOnTheAdServerRequest
{
    self.adServerValidationKeyValueState = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didNotFindPrebidKeywordsOnTheAdServerRequest
{
    self.adServerValidationKeyValueState = 2;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)adServerDidNotRespondWithPrebidCreative
{
    self.adServerValidationPBMCreativeState = 2;
    self.adServerValidationState = 2;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)adServerRespondedWithPrebidCreative
{
    self.adServerValidationPBMCreativeState = 1;
    if (self.adServerValidationKeyValueState == 1) {
        self.adServerValidationState = 1;
    } else {
        self.adServerValidationState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void) startDemandValidation
{
    self.demandValidationState = 0;
    self.demandValidationBidRequestSentState = 0;
    self.demandValidataionBidResponseReceivedState = 0;
    self.validator2 = [[DemandValidator alloc] init];
    [self.validator2 startTestWithCompletionHandler:^() {
        int totalBids = [[self.validator2.testResults objectForKey:@"totalBids"] intValue];
        if (totalBids > 0) {
            self.demandValidataionBidResponseReceivedState = 1;
            self.demandValidationState = 1;
        } else {
            self.demandValidataionBidResponseReceivedState = 2;
            self.demandValidationState = 2;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    self.demandValidationBidRequestSentState = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}



@end
