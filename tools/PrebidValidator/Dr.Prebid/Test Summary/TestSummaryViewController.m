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
#import "PBVPrebidSDKValidator.h"
#import "SDKValidationResponseViewController.h"


NSString *__nonnull const kSectionCellString = @"sCell";
NSString *__nonnull const kHeaderCellString = @"headerCell";

@interface TestSummaryViewController ()<PBVLineItemsSetupValidatorDelegate, PBVPrebidSDKValidatorDelegate,
UITableViewDataSource, UITableViewDelegate>

@property NSArray *sectionTitles;

@property NSIndexPath *selectedIndex;

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

@property PBVPrebidSDKValidator *validator3;
@property int sdkValidationState;
@property int sdkAdUnitRegistrationState;
@property int sdkRequestToPrebidServerState;
@property int sdkPrebidServerResponseState;
@property int sdkBidReceivedState;
@property int sdkKeyValueState;
@property int sdkPBMCreativeState;
@end

@implementation TestSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Summary";
    
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
    [self startSDKValidation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) return 2;
    if(section == 2)
        return 6;
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TestHeaderCell *cell = (TestHeaderCell *)[tableView dequeueReusableCellWithIdentifier:kHeaderCellString];
    
    if(cell == nil)
        return nil;
    if(section == 0){
        if(self.adServerValidationState == 1) {
            cell.imgStatus.image = [UIImage imageNamed:@"passedMain"];
        } else if (self.adServerValidationState == 2) {
            cell.imgStatus.image = [UIImage imageNamed:@"failedMain"];
        } else {
             cell.imgStatus.image = nil;
        }

    } else if (section == 1){
        if (self.demandValidationState == 1) {
            cell.imgStatus.image = [UIImage imageNamed:@"passedMain"];
        } else if (self.demandValidationState == 2) {
            cell.imgStatus.image = [UIImage imageNamed:@"failedMain"];
        } else {
            cell.imgStatus.image = nil;
        }
    } else if (section == 2) {
        if (self.sdkValidationState == 1) {
            cell.imgStatus.image = [UIImage imageNamed:@"passedMain"];
        } else if (self.sdkValidationState == 2) {
            cell.imgStatus.image = [UIImage imageNamed:@"failedMain"];
        } else {
            cell.imgStatus.image = nil;
        }
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
    } else if (indexPath.section == 2 && indexPath.row == 4) {
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
            controller.resultsDictionary = self.validator2.testResults;
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (indexPath.section == 2 && indexPath.row == 4) {
        if (self.sdkValidationState > 0) {
            KVViewController * kvController = [[KVViewController alloc] initWithRequestString:[self.validator3 getAdServerRequest]];
            [self.navigationController pushViewController:kvController animated:YES];
        }
    } else if (indexPath.section == 2 && indexPath.row == 5) {
        if (self.sdkValidationState > 0) {
            SDKValidationResponseViewController *controller = [[SDKValidationResponseViewController alloc] initWithValidator:self.validator3];
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
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.adServerValidationKeyValueState == 2) {
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
       
    } else if(indexPath.row == 1){
        
        if(self.adServerValidationPBMCreativeState == 1){
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.adServerValidationPBMCreativeState == 2) {
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
        cell.lblHeader.text = kpbmjsreceived;
       
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
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.demandValidationBidRequestSentState == 2){ // it should never equal to 2
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
        return cell;
        
    } else if(indexPath.row == 1){
        if (self.demandValidataionBidResponseReceivedState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.demandValidataionBidResponseReceivedState == 2) {
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
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
            cpmCell.lblHeader.text = [NSString stringWithFormat:@"$%.02f avg CPM",[[self.validator2.testResults objectForKey:@"avgCPM"] doubleValue]] ;
            
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
    if (indexPath.row == 0){
        cell.lblHeader.text = kAdUnitRegistered;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkAdUnitRegistrationState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkAdUnitRegistrationState == 2){ // it should never equal to 2
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
    } else if(indexPath.row == 1){
        cell.lblHeader.text = kRequestToPrebidServerSent;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkRequestToPrebidServerState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkRequestToPrebidServerState == 2){
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
    } else if (indexPath.row == 2){
        cell.lblHeader.text = kPrebidServerResponseReceived;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkPrebidServerResponseState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkPrebidServerResponseState == 2){
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
    } else if(indexPath.row == 3){
        cell.lblHeader.text = kBidReceived;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkBidReceivedState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkBidReceivedState == 2){
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
    } else if(indexPath.row == 4){
        cell.lblHeader.text = kAdServerRequestSentWithKV;
        if (self.sdkKeyValueState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkKeyValueState == 2){
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
    } else if (indexPath.row == 5) {
        cell.lblHeader.text = kpbmjsreceived;
        if (self.sdkPBMCreativeState == 1) {
            cell.imageView.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkPBMCreativeState == 2){
            cell.imageView.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imageView.image = nil;
        }
    }
    return cell;

}

#pragma mark AdServerValidation

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
    if (self.adServerValidationKeyValueState == 0) {
        // This is to capture the case that
        // when user input invalid DFP ad unit id
        // DFP won't send any request
        // so the state will be stale at 0
        // does not apply to MoPub
        self.adServerValidationKeyValueState = 2;
    }
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
        self.adServerValidationKeyValueState = 2;
        self.adServerValidationState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark DemandValidation

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

#pragma mark SDKValidation

- (void) startSDKValidation
{
    self.sdkValidationState = 0;
    self.sdkAdUnitRegistrationState = 0;
    self.sdkRequestToPrebidServerState = 0;
    self.sdkPrebidServerResponseState = 0;
    self.sdkBidReceivedState = 0;
    self.sdkKeyValueState = 0;
    self.sdkPBMCreativeState = 0;
    self.validator3 = [[PBVPrebidSDKValidator alloc] initWithDelegate:self];
    [self.validator3 startTest];
}
- (void)adUnitRegistered
{
    self.sdkAdUnitRegistrationState = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)requestToPrebidServerSent:(Boolean)sent
{
    if (sent) {
        self.sdkRequestToPrebidServerState = 1;
    } else {
        self.sdkRequestToPrebidServerState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)prebidServerResponseReceived:(Boolean)received
{
    if (received) {
        self.sdkPrebidServerResponseState = 1;
    } else {
        self.sdkPrebidServerResponseState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)bidReceivedAndCached: (Boolean) received
{
    if (received) {
        self.sdkBidReceivedState = 1;
    } else {
        self.sdkBidReceivedState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)adServerRequestSent:(NSString *)adServerRequest
{
    if (adServerRequest!= nil && [adServerRequest containsString:@"hb_cache_id"]) {
        self.sdkKeyValueState = 1;
    } else {
        self.sdkKeyValueState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void) adServerResponseContainsPBMCreative:(Boolean)contains
{
    if (contains) {
        self.sdkPBMCreativeState = 1;
    } else {
        self.sdkPBMCreativeState = 2;
    }
    if (self.sdkAdUnitRegistrationState == 1 &&
        self.sdkRequestToPrebidServerState == 1 &&
        self.sdkPrebidServerResponseState == 1 &&
        self.sdkBidReceivedState == 1 &&
        self.sdkKeyValueState == 1 &&
        self.sdkPBMCreativeState == 1) {
        self.sdkValidationState = 1;
    } else {
        self.sdkValidationState = 2;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
