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

#import "TestSummaryViewController.h"
#import "SectionCell.h"
#import "TestHeaderCell.h"
#import "PBVLineItemsSetupValidator.h"
#import "CPMSectionCell.h"
#import "KeyValueController.h"
#import "KVViewController.h"
#import "AdServerResponseViewController.h"
#import "DemandValidator.h"
#import "DemandViewController.h"
#import "HelpViewController.h"
#import "PBVSharedConstants.h"
#import "PBVPrebidSDKValidator.h"
#import "SDKValidationResponseViewController.h"
#import "AppDelegate.h"


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

@property NSTimer *pingTimer;

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
    [self.tableView setUserInteractionEnabled:FALSE];
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                      target:self selector:@selector(checkIfLoadingIsComplete) userInfo:nil repeats:YES];
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
            [self showLoadingIndicator: cell.imgStatus];
            
        }

    } else if (section == 1){
        if (self.demandValidationState == 1) {
            cell.imgStatus.image = [UIImage imageNamed:@"passedMain"];
        } else if (self.demandValidationState == 2) {
            cell.imgStatus.image = [UIImage imageNamed:@"failedMain"];
        } else {
             [self showLoadingIndicator: cell.imgStatus];
        }
    } else if (section == 2) {
        if (self.sdkValidationState == 1) {
            cell.imgStatus.image = [UIImage imageNamed:@"passedMain"];
        } else if (self.sdkValidationState == 2) {
            cell.imgStatus.image = [UIImage imageNamed:@"failedMain"];
        } else {
             [self showLoadingIndicator: cell.imgStatus];
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

-(void) showLoadingIndicator:(UIImageView *) imageView {
    NSMutableArray *imageCollection = [NSMutableArray arrayWithCapacity:11];
    
    for(int i=1; i<=36; i++){
        NSString *imageName = [NSString stringWithFormat:@"%dloading_icon", i];
        UIImage *myImage = [UIImage imageNamed:imageName];
        [imageCollection addObject: myImage];
    }
    
    imageView.animationImages = imageCollection;
    imageView.animationDuration = 1.50f;
    imageView.animationRepeatCount = 0;
    [imageView startAnimating];
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
    
    if ((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 2) || (indexPath.section == 2 && indexPath.row == 4)){
        return 61.0f;
    }
    return 39.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 61.0f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        KeyValueController * controller = [storyboard instantiateViewControllerWithIdentifier:@"keyValueView"];
        controller.requestString = [self.validator1 getAdServerRequest];
        controller.postDataString = [self.validator1 getAdServerPostData];
        
        [self.navigationController pushViewController:controller animated:YES];
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
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            KeyValueController * controller = [storyboard instantiateViewControllerWithIdentifier:@"keyValueView"];
            controller.requestString = [self.validator3 getAdServerRequest];
            controller.postDataString = [self.validator3 getAdServerRequestPostData];
            
            [self.navigationController pushViewController:controller animated:YES];
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
    } else {
        return [self configurePrebidMobileSDKSection:self.tableView withIndexPath:indexPath];
    }
    
   // return nil;
}

-(UITableViewCell *) configureAdServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    SectionCell *cell = (SectionCell *)[self.tableView dequeueReusableCellWithIdentifier:kSectionCellString ];

    if(cell == nil)
        return nil;
    if (indexPath.row == 0){
        cell.lblHeader.numberOfLines = 0;
       cell.lblHeader.text = kAdServerRequestSentWithKV;
        
        if(self.adServerValidationKeyValueState == 1){
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.adServerValidationKeyValueState == 2) {
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
       
    } else if(indexPath.row == 1){
        
        if(self.adServerValidationPBMCreativeState == 1){
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.adServerValidationPBMCreativeState == 2) {
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
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
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.demandValidationBidRequestSentState == 2){ // it should never equal to 2
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
        return cell;
        
    } else if(indexPath.row == 1){
        if (self.demandValidataionBidResponseReceivedState == 1) {
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
            NSNumber *totalBids = [self.validator2.testResults objectForKey:@"totalBids"];
            if (totalBids != nil) {
                cell.lblHeader.text = [NSString stringWithFormat:@"%d bid responses received", [totalBids intValue] ];
            } else {
                cell.lblHeader.text = kBidResponseReceived;
            }
        } else if (self.demandValidataionBidResponseReceivedState == 2) {
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
            NSNumber *totalBids = [self.validator2.testResults objectForKey:@"totalBids"];
            if (totalBids != nil) {
                cell.lblHeader.text = [NSString stringWithFormat:@"%d bid responses received", [totalBids intValue] ];
            } else {
                cell.lblHeader.text = kBidResponseReceived;
            }
        } else {
            cell.imgResult.image = nil;
            cell.lblHeader.text = kBidResponseReceived;
        }

        return cell;
        
    } else if(indexPath.row == 2){
        
        CPMSectionCell *cpmCell = (CPMSectionCell *)[tableView dequeueReusableCellWithIdentifier:@"cpmCell"];
        cpmCell.lblHeader.text = @"$0.00 avg CPM";
        if (self.demandValidationState >0) {
            
            //check nil & nan
            if(!isnan([[self.validator2.testResults objectForKey:@"avgCPM"] doubleValue])){
               cpmCell.lblHeader.text = [NSString stringWithFormat:@"$%.02f Average CPM",[[self.validator2.testResults objectForKey:@"avgCPM"] doubleValue]];
            }

            
            if(!isnan([[self.validator2.testResults objectForKey:@"avgResponse"] doubleValue])){
                cpmCell.lblHeader2.text = [NSString stringWithFormat:@"%ldms average response time",[[self.validator2.testResults objectForKey:@"avgResponse"] integerValue]] ;
            }

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
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkAdUnitRegistrationState == 2){ // it should never equal to 2
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
    } else if(indexPath.row == 1){
        cell.lblHeader.text = kRequestToPrebidServerSent;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkRequestToPrebidServerState == 1) {
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkRequestToPrebidServerState == 2){
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
    } else if (indexPath.row == 2){
        cell.lblHeader.text = kPrebidServerResponseReceived;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkPrebidServerResponseState == 1) {
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkPrebidServerResponseState == 2){
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
    } else if(indexPath.row == 3){
        cell.lblHeader.text = kCreativeCached;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (self.sdkBidReceivedState == 1) {
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkBidReceivedState == 2){
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
    } else if(indexPath.row == 4){
        cell.lblHeader.numberOfLines = 0;
        cell.lblHeader.text = kAdServerRequestSentWithKV;
        if (self.sdkKeyValueState == 1) {
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkKeyValueState == 2){
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
        }
    } else if (indexPath.row == 5) {
        cell.lblHeader.text = kpbmjsreceived;
        if (self.sdkPBMCreativeState == 1) {
            cell.imgResult.image = [UIImage imageNamed:@"passedStep"];
        } else if (self.sdkPBMCreativeState == 2){
            cell.imgResult.image = [UIImage imageNamed:@"failedStep"];
        } else {
            cell.imgResult.image = nil;
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
- (void)adServerDidNotRespondWithPrebidCreative:(NSError *) errorDetails
{
    self.adServerValidationPBMCreativeState = 2;
    self.adServerValidationState = 2;
    if (self.adServerValidationKeyValueState == 0) {
        // This is to capture the case that
        // when user input invalid DFP ad unit id
        // DFP won't send any request
        // so the state will be stale at 0
        // does not apply to MoPub
        if(errorDetails != nil){
            NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
            NSString *errorString = [NSString stringWithFormat:@"%@ %@", adServerName, errorDetails.description];
        
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid AdUnit Request" message:errorString preferredStyle:UIAlertControllerStyleAlert];
        
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction
                                                                                                                  *action){[self.navigationController popViewControllerAnimated:YES];}];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
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

- (void)adServerRequestSent:(NSString *)adServerRequest andPostData:(NSString *)postData
{
    if (adServerRequest!= nil && (([adServerRequest containsString:@"hb_cache_id"] && [adServerRequest containsString:@"hb_pb"]) || ([postData containsString:@"hb_cache_id"] && [postData containsString:@"hb_pb"]))) {
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

-(void) checkIfLoadingIsComplete {
    if(self.adServerValidationState > 0 && self.demandValidationState > 0 && self.sdkValidationState > 0){
        [self.tableView setUserInteractionEnabled:TRUE];
        
        [self.pingTimer invalidate];
    }
}
@end
