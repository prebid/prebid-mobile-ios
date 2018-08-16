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
#import "AdSizeController.h"
#import "IDInputViewController.h"
#import "PBVSharedConstants.h"
#import "TestSummaryViewController.h"

NSString *__nonnull const kGeneralInfoText = @"General Info";
NSString *__nonnull const kAdFormatBanner = @"Banner";
NSString *__nonnull const kAdFormatInterstitial = @"Interstitial";

NSString *__nonnull const kAdServerInfoText = @"AdServer Info";
NSString *__nonnull const kAdServerDFP = @"DFP";
NSString *__nonnull const kAdServerMoPub = @"MoPub";

NSString *__nonnull const kPrebidServerInfoText = @"Prebid Server Info";
NSString *__nonnull const kPrebidHostAppnexus = @"AppNexus";
NSString *__nonnull const kPrebidHostRubicon = @"Rubicon";

NSString *__nonnull const kAdFormatText = @"Ad Format";
NSString *__nonnull const kAdSizeText = @"Ad Size";

NSString *__nonnull const kAdServerLabel = @"Ad Server";
NSString *__nonnull const kBidPriceLabel = @"Bid Price";

NSString *__nonnull const KPBHostLabel = @"Server Host";


@interface SettingsTableViewController ()<UITextFieldDelegate, AdSizeProtocol, IdProtocol>

@property NSDictionary *tableViewDictionaryItems;
@property NSArray *sectionTitles;
@property NSArray *generalInfoTitles;
@property NSArray *adServerTitles;
@property NSArray *prebidServerTitles;

@property NSString *chosenAdSize;
@property NSString *adUnitID;
@property NSString *accountID;
@property NSString *configID;
@property NSIndexPath *selectedIndex;
@property NSString *bidPrice;
@property BOOL isInterstitial;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Doctor Prebid";
    
    self.isInterstitial = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(btnAboutPressed:)];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0]];
    
    // remove the scrolling of tableview
    self.tableView.scrollEnabled = NO;
    self.chosenAdSize = @"300x250";
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.generalInfoTitles = @[kAdFormatText, kAdSizeText];
    self.adServerTitles = @[kAdServerLabel, kBidPriceLabel, kAdUnitIdText];
    self.prebidServerTitles = @[KPBHostLabel, kPBAccountIDText, kPBConfigIDText];
    
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
    return self.sectionTitles.count ;
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

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(nonnull NSIndexPath *)indexPath {
    self.selectedIndex = indexPath;
    [self btnAboutPressed:self];
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
        if(indexPath.row == 0){
            return 55.0f;
        } else if(indexPath.row == 1){
            return 40.0f;
        }
    } else if(indexPath.section == 1){
        if(indexPath.row == 0){
            return 55.0f;
        } else if(indexPath.row == 1){
            return 40.0f;
        }else {
            return 61.0f;
        }
    } else if(indexPath.section == 2){
        if(indexPath.row == 0){
            return 55.0f;
        }
    }
    
    return 61.0f;
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
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        
        if(self.isInterstitial) // we dont provide size selection for interstitial
            return;
        AdSizeController *controller = [[AdSizeController alloc] init];
        [controller setTitle:@"Ad Size"];
        controller.delegate = self;
        controller.settingsSize = self.chosenAdSize;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        IDInputViewController * idController = [storyboard instantiateViewControllerWithIdentifier:@"idController"];
        idController.delegate = self;
        [idController setTitle:kAdUnitIdText];
        idController.idInputText.text = self.adUnitID;
        [self.navigationController pushViewController:idController animated:YES];
        
    } else if (indexPath.section == 2 && indexPath.row == 1){
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        IDInputViewController * idController = [storyboard instantiateViewControllerWithIdentifier:@"idController"];
        idController.delegate = self;
        [idController setTitle:kPBAccountIDText];
        idController.idInputText.text = self.accountID;
        [self.navigationController pushViewController:idController animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 2){
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        IDInputViewController * idController = [storyboard instantiateViewControllerWithIdentifier:@"idController"];
        idController.delegate = self;
        [idController setTitle:kPBConfigIDText];
        idController.idInputText.text = self.configID;
        [self.navigationController pushViewController:idController animated:YES];
    }
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
        [nextButton setTitle:@"Run Tests" forState:UIControlStateNormal];
        nextButton.frame = CGRectMake(0.0, 0.0, 335.0, 35.0);
        [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextButton setBackgroundColor:[UIColor colorWithRed:0.93 green:0.59 blue:0.12 alpha:1.0]];
        [nextButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [nextButton addTarget:self action:@selector(didPressNext:) forControlEvents:UIControlEventTouchUpInside];
        nextButton.clipsToBounds = YES;
        if([self checkIfTestButtonCanBeDisabled] == FALSE){
            nextButton.enabled = NO;
            [nextButton setBackgroundColor:[UIColor colorWithRed:0.93 green:0.59 blue:0.12 alpha:0.3]];
        }else{
            nextButton.enabled = YES;
        }
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
            NSArray *adFormatItems = @[kAdFormatBanner, kAdFormatInterstitial];
            [cell.segmentControl setTitle:adFormatItems[0] forSegmentAtIndex:0];
            [cell.segmentControl setTitle:adFormatItems[1] forSegmentAtIndex:1];
            [cell.segmentControl addTarget:self action:@selector(adFormatChanged:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *labelAccessoryCell = @"LabelAccessoryCell";
        
        LabelAccessoryCell *cell = (LabelAccessoryCell *)[tableView dequeueReusableCellWithIdentifier:labelAccessoryCell];
        
        if(cell != nil){
            cell.lblTitle.text = kAdSizeText;
            cell.lblSelectedContent.enabled = NO;
            if(self.isInterstitial == NO){
                if(self.chosenAdSize == nil || [self.chosenAdSize isEqualToString:@""]){
                    cell.lblSelectedContent.text = @"300x250";
                } else {
                    cell.lblSelectedContent.text = self.chosenAdSize;
                }
                [cell.lblSelectedContent setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.lblSelectedContent.text = @"Interstitial";
                [cell.lblSelectedContent setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
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
            NSArray *adServerItems = @[kAdServerDFP, kAdServerMoPub];
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
            if(self.bidPrice != nil && ![self.bidPrice isEqualToString:@""]){
                cell.lblSelectedContent.text = self.bidPrice;
            }else {
                cell.lblSelectedContent.text = @"$0.00";
            }
            cell.lblSelectedContent.keyboardType = UIKeyboardTypeNumberPad;
            [cell.lblSelectedContent addTarget:self action:@selector(currencyFieldChange:) forControlEvents:UIControlEventEditingChanged];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            UIToolbar  *numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            
            numberToolbar.items = [NSArray arrayWithObjects:
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad:)],
                                   nil];
            cell.lblSelectedContent.inputAccessoryView = numberToolbar;
            cell.lblSelectedContent.delegate = self;

        }
        return cell;
    }
    else if (indexPath.row == 2){
        static NSString *idCell = @"IdCell";
        
         IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kAdUnitIdText;
            if (self.adUnitID == nil || [self.adUnitID isEqualToString:@""]) {
                cell.lblId.text = @"ie: /0000/xxxx/000/xxxx";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else {
                cell.lblId.text = self.adUnitID;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }

        }
        return cell;
    }
    
    return nil;
}

- (IBAction)doneWithNumberPad:(UIBarButtonItem *)sender
{
    [self.tableView endEditing:YES];
}

- (UITableViewCell *) configurePrebidServerSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        static NSString *segmentCell = @"SegmentCell";
        
        SegmentCell *cell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:segmentCell];
        
        if(cell != nil){
            cell.labelText.text = KPBHostLabel;
            NSArray *adServerItems = @[kPrebidHostAppnexus, kPrebidHostRubicon];
            [cell.segmentControl setTitle:adServerItems[0] forSegmentAtIndex:0];
            [cell.segmentControl setTitle:adServerItems[1] forSegmentAtIndex:1];
        }
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kPBAccountIDText;
            if (self.accountID == nil || [self.accountID isEqualToString:@""]) {
                cell.lblId.text = @"ie: 00000-0000-0000-00000-00000-00000";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else {
                cell.lblId.text = self.accountID;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }
    else if (indexPath.row == 2){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kPBConfigIDText;
            if (self.configID == nil || [self.configID isEqualToString:@""]) {
                cell.lblId.text = @"ie: 00000-0000-0000-00000-00000-00000";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else{
                cell.lblId.text = self.configID;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }
    
    return nil;
}

#pragma mark - Actions

-(void) btnAboutPressed :(id)sender {
    HelpViewController *controller = nil;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        controller = [[HelpViewController alloc] initWithTitle:kAboutString];
    } else if ([sender isKindOfClass:[SettingsTableViewController class]]) {
        if (self.selectedIndex.section == 0) {
            controller = [[HelpViewController alloc] initWithTitle:kGeneralInfoHelpString];
        } else if (self.selectedIndex.section == 1) {
            controller = [[HelpViewController alloc] initWithTitle:kAdServerInfoHelpString];
        } else {
            controller = [[HelpViewController alloc] initWithTitle:kPrebidServerInfoHelpString];
        }
    }
    if (controller != nil) {
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

#pragma mark - UITextField delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 7;
}


-(void) currencyFieldChange: (id) sender {
    
    UITextField *currencyField = (UITextField *)sender;
    if(currencyField.text.length > 7)
        return;
    NSString *amountString = [self currencyFormatting:currencyField.text];
    currencyField.text = amountString;
    self.bidPrice = amountString;
}

-(NSString *) currencyFormatting :(NSString *) currency {
    
    NSNumber *inputNumber;
    NSNumberFormatter *inputFormatter = [[NSNumberFormatter alloc] init];
    inputFormatter.numberStyle = NSNumberFormatterCurrencyAccountingStyle;
    inputFormatter.currencySymbol = @"$";
    inputFormatter.maximumFractionDigits = 2;
    inputFormatter.minimumFractionDigits = 2;
    
    NSError *error = NULL;
    NSRegularExpression *expPattern = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *newCurrency = [expPattern stringByReplacingMatchesInString:currency options:0 range:NSMakeRange(0, currency.length) withTemplate:@""];
    
    double doubleValue = newCurrency.doubleValue;
    
    inputNumber = [NSNumber numberWithDouble:doubleValue/100];

    if(inputNumber == 0)
        return @"";
    else
        return [inputFormatter stringFromNumber:inputNumber];
}

-(void) adFormatChanged:(id) sender {
    UISegmentedControl *adTypeSegment = (UISegmentedControl *) sender;
    
    if(adTypeSegment.selectedSegmentIndex == 1){
        self.isInterstitial = YES;
    } else if(adTypeSegment.selectedSegmentIndex == 0){
        self.isInterstitial = NO;
    }
    [self.tableView reloadData];
    NSLog(@"came here");
    
}

-(void) sendSelectedAdSize:(NSString *)adSize {
    if(adSize != nil && ![adSize isEqualToString:@""]){
        self.chosenAdSize = adSize;
        [self.tableView reloadData];
    }
}

-(void) sendSelectedId:(NSString *)idString forID:(NSString *) idLabel{
    
    if([idLabel isEqualToString:kAdUnitIdText]){
        self.adUnitID = idString;
    } else if( [idLabel isEqualToString: kPBAccountIDText]) {
        self.accountID = idString;
    } else if([idLabel isEqualToString:kPBConfigIDText]) {
        self.configID = idString;
    }
    [self.tableView reloadData];
    
}

-(void) didPressNext:(id) sender {
    
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];
            
            if(section == 0 && row == 0 && [cell isKindOfClass:[SegmentCell class]]){
                SegmentCell *segmentCell = (SegmentCell *) cell;
                if(segmentCell.segmentControl.selectedSegmentIndex == 0){
                    [[NSUserDefaults standardUserDefaults] setObject:kAdFormatBanner forKey:kAdFormatNameKey];
                    
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:kAdFormatInterstitial forKey:kAdFormatNameKey];
                }
            }
            
            if(section == 0 && row == 1 && [cell isKindOfClass:[LabelAccessoryCell class]]){
                LabelAccessoryCell *labelCell = (LabelAccessoryCell *) cell;
                [[NSUserDefaults standardUserDefaults] setObject:labelCell.lblSelectedContent.text forKey:kAdSizeKey];
                
            }
            
            if(section == 1 && row == 0 && [cell isKindOfClass:[SegmentCell class]]){
                SegmentCell *segmentCell = (SegmentCell *) cell;
                if(segmentCell.segmentControl.selectedSegmentIndex == 0){
                    [[NSUserDefaults standardUserDefaults] setObject:kAdServerDFP forKey:kAdServerNameKey];
                    
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:kAdServerMoPub forKey:kAdServerNameKey];
                    
                }
            }
            
            if(section == 1 && row == 1 && [cell isKindOfClass:[LabelAccessoryCell class]]){
                LabelAccessoryCell *labelCell = (LabelAccessoryCell *) cell;
                [[NSUserDefaults standardUserDefaults] setObject:labelCell.lblSelectedContent.text forKey:kBidPriceKey];
            }
            
            if(section == 1 && row == 2 && [cell isKindOfClass:[IdCell class]]){
                IdCell *idCell = (IdCell *) cell;
                [[NSUserDefaults standardUserDefaults] setObject:idCell.lblId.text forKey:kAdUnitIdKey];
            }
            
            if(section == 2 && row == 0 && [cell isKindOfClass:[SegmentCell class]]){
                SegmentCell *segmentCell = (SegmentCell *) cell;
                if(segmentCell.segmentControl.selectedSegmentIndex == 0){
                    [[NSUserDefaults standardUserDefaults] setObject:kPrebidHostAppnexus forKey:kPBHostKey];
                    
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:kPrebidHostRubicon forKey:kPBHostKey];
                    
                }
            }
            
            if(section == 2 && row == 1 && [cell isKindOfClass:[IdCell class]]){
                IdCell *idCell = (IdCell *) cell;
                [[NSUserDefaults standardUserDefaults] setObject:idCell.lblId.text forKey:kPBAccountKey];
            }
            
            if(section == 2 && row == 2 && [cell isKindOfClass:[IdCell class]]){
                IdCell *idCell = (IdCell *) cell;
                [[NSUserDefaults standardUserDefaults] setObject:idCell.lblId.text forKey:kPBConfigKey];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    TestSummaryViewController *summaryViewController = [[TestSummaryViewController alloc] init];
    [self.navigationController pushViewController:summaryViewController animated:YES];
}

-(BOOL) checkIfTestButtonCanBeDisabled {
    
    if(self.isInterstitial == FALSE && (self.chosenAdSize == nil || [self.chosenAdSize isEqualToString:@""]))
        return FALSE;
    
    if(self.adUnitID == nil || [self.adUnitID isEqualToString:@""])
        return FALSE;
    
    if(self.accountID == nil || [self.accountID isEqualToString:@""])
        return FALSE;
    
    if(self.configID == nil || [self.configID isEqualToString:@""])
        return FALSE;
    
    if(self.bidPrice == nil || [self.bidPrice isEqualToString:@""])
        return FALSE;
    
    return TRUE;
}

@end
