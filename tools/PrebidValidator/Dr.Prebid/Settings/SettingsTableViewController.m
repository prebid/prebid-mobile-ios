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
#import "FooterCell.h"
#import "IdCell.h"
#import "AdSizeController.h"
#import "AdFormatController.h"
#import "IDInputViewController.h"
#import "PBVSharedConstants.h"
#import "TestSummaryViewController.h"
#import "ToolReachability.h"
#import "AppDelegate.h"

NSString *__nonnull const kGeneralInfoText = @"General Info";
NSString *__nonnull const kAdFormatBanner = @"Banner";
NSString *__nonnull const kAdFormatInterstitial = @"Interstitial";
NSString *__nonnull const kAdFormatNative = @"Native";
NSString *__nonnull const kAdFormatVideo = @"Video";

NSString *__nonnull const kAdServerInfoText = @"AdServer Info";
NSString *__nonnull const kAdServerDFP = @"DFP";

NSString *__nonnull const kPrebidServerInfoText = @"Prebid Server Info";
NSString *__nonnull const kPrebidHostAppnexus = @"Xandr";
NSString *__nonnull const kPrebidHostRubicon = @"Rubicon";
NSString *__nonnull const kPrebidHostCustom = @"Custom";

NSString *__nonnull const kfooter = @"footer";

NSString *__nonnull const kAdFormatText = @"Ad Format";
NSString *__nonnull const kAdSizeText = @"Ad Size";

NSString *__nonnull const kAdServerLabel = @"Ad Server";
NSString *__nonnull const kBidPriceLabel = @"Bid Price";

NSString *__nonnull const KPBHostLabel = @"Server Host";


@interface SettingsTableViewController ()<UITextFieldDelegate, AdSizeProtocol, IdProtocol,AdFormatProtocol, UIPickerViewDelegate, UIPickerViewDataSource>

@property NSDictionary *tableViewDictionaryItems;
@property NSArray *sectionTitles;
@property NSArray *generalInfoTitles;
@property NSArray *adServerTitles;
@property NSArray *prebidServerTitles;

@property NSString *chosenAdSize;
@property NSString *chosenAdFormat;
@property NSString *adUnitID;
@property NSString *customHost;
@property NSString *accountID;
@property NSString *configID;
@property NSIndexPath *selectedIndex;
@property NSString *bidPrice;
@property BOOL isInterstitial;
@property BOOL hideCustomHost;

@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Doctor Prebid";
    
    self.isInterstitial = NO;
    self.hideCustomHost = ![[[NSUserDefaults standardUserDefaults] objectForKey:kPBHostKey] isEqualToString: kPrebidHostCustom];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(btnAboutPressed:)];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0]];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.generalInfoTitles = @[kAdFormatText, kAdSizeText];
    self.adServerTitles = @[kAdServerLabel, kBidPriceLabel, kAdUnitIdText];
    self.prebidServerTitles = @[KPBHostLabel, kPBCustomHostText, kPBAccountIDText, kPBConfigIDText];
    
    self.tableViewDictionaryItems = @{kGeneralInfoText :self.generalInfoTitles, kAdServerInfoText:self.adServerTitles, kPrebidServerInfoText: self.prebidServerTitles};
    
    self.sectionTitles = @[kGeneralInfoText, kAdServerInfoText, kPrebidServerInfoText, kfooter];

    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:(CGRect){{0, self.view.frame.size.height-300}, self.view.frame.size.width, 200}];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    //self.pickerView.showsSelectionIndicator = true;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.hidden = YES;
    [self.view addSubview:self.pickerView];
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
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
    
    if(section != 3){
    static NSString *headerCell = @"HeaderCell";
    
    HeaderCell *cell = (HeaderCell *)[tableView dequeueReusableCellWithIdentifier:headerCell];
    
    if(cell != nil){
        NSString *titleText = [self.sectionTitles objectAtIndex:section];
        
        cell.lblHeader.text = titleText;
    }
    return cell;
    } else {
        static NSString *footerCell = @"FooterCell";
        
        FooterCell *cell = (FooterCell *)[tableView dequeueReusableCellWithIdentifier:footerCell];
        
        [cell.btnRunTests addTarget:self action:@selector(didPressNext:) forControlEvents:UIControlEventTouchUpInside];
        if([self checkIfTestButtonCanBeDisabled] == FALSE){
            cell.btnRunTests.enabled = NO;
            [cell.btnRunTests setBackgroundColor:[UIColor colorWithRed:0.93 green:0.59 blue:0.12 alpha:0.3]];
        }else{
            cell.btnRunTests.enabled = YES;
        }
        return cell;
    }
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
    
    if(indexPath.section == 0 && indexPath.row == 0 && [cell isKindOfClass:[LabelAccessoryCell class]]){
        LabelAccessoryCell *labelCell = (LabelAccessoryCell *) cell;
        [[NSUserDefaults standardUserDefaults] setObject:labelCell.lblSelectedContent.text forKey:kAdFormatNameKey];
    }
    
    if(indexPath.section == 0 && indexPath.row == 1 && [cell isKindOfClass:[LabelAccessoryCell class]]){
        LabelAccessoryCell *labelCell = (LabelAccessoryCell *) cell;
        [[NSUserDefaults standardUserDefaults] setObject:labelCell.lblSelectedContent.text forKey:kAdSizeKey];
        
    }
    
    if(indexPath.section == 1 && indexPath.row == 0 && [cell isKindOfClass:[SegmentCell class]]){
        SegmentCell *segmentCell = (SegmentCell *) cell;
        if(segmentCell.segmentControl.selectedSegmentIndex == 0){
            [[NSUserDefaults standardUserDefaults] setObject:kAdServerDFP forKey:kAdServerNameKey];
        }
    }
    
    if(indexPath.section == 1 && indexPath.row == 1 && [cell isKindOfClass:[LabelAccessoryCell class]]){
        NSArray *bidPriceArray = [self.bidPrice componentsSeparatedByString:@"$"];
        [[NSUserDefaults standardUserDefaults] setObject:bidPriceArray[1] forKey:kBidPriceKey];
    }
    
    if(indexPath.section == 1 && indexPath.row == 2 && [cell isKindOfClass:[IdCell class]]){
        IdCell *idCell = (IdCell *) cell;
        NSString *trimmedId = [self removeSpacesAndNewLines:idCell.lblId.text];
        [[NSUserDefaults standardUserDefaults] setObject:trimmedId forKey:kAdUnitIdKey];
    }
    if(indexPath.section == 2 && indexPath.row == 1 && [cell isKindOfClass:[IdCell class]]){
          IdCell *idCell = (IdCell *) cell;
          NSString *trimmedId = [self removeSpacesAndNewLines:idCell.lblId.text];
          [[NSUserDefaults standardUserDefaults] setObject:trimmedId forKey:kPBCustomHostKey];
      }
    if(indexPath.section == 2 && indexPath.row == 2 && [cell isKindOfClass:[IdCell class]]){
        IdCell *idCell = (IdCell *) cell;
        NSString *trimmedId = [self removeSpacesAndNewLines:idCell.lblId.text];
        [[NSUserDefaults standardUserDefaults] setObject:trimmedId forKey:kPBAccountKey];
    }
    
    if(indexPath.section == 2 && indexPath.row == 3 && [cell isKindOfClass:[IdCell class]]){
        IdCell *idCell = (IdCell *) cell;
        NSString *trimmedId = [self removeSpacesAndNewLines:idCell.lblId.text];
        [[NSUserDefaults standardUserDefaults] setObject:trimmedId forKey:kPBConfigKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0){
        return 2;
    } else if(section == 3){
        return 0;
    } else if (section == 2){
        return 4;
    }
    
    return 3;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return 53.0f;
        } else if(indexPath.row == 1){
            return 40.0f;
        }
    } else if(indexPath.section == 1){
        if(indexPath.row == 0){
            return 55.0f;
        } else if(indexPath.row == 1){
            return 45.0f;
        }else {
            return 61.0f;
        }
    } else if(indexPath.section == 2){
        if(indexPath.row == 0){
            return 55.0f;
        } else if (indexPath.row == 1){
            if (self.hideCustomHost) {
                return 0.0f;
            } else {
                return 61.0f;
            }
        }
    } else if(indexPath.section == 3){
        return 0;
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
    
    if(indexPath.section == 0 && indexPath.row == 0){
        AdFormatController *controller = [[AdFormatController alloc] init];
        [controller setTitle:@"Ad Format"];
        controller.delegate = self;
        controller.settingsAdFormat = self.chosenAdFormat;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        
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
        
    }else if (indexPath.section == 2 && indexPath.row == 0){
        self.pickerView.hidden = NO;
        [self.view bringSubviewToFront:self.pickerView];
    }else if (indexPath.section == 2 && indexPath.row == 1){
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        IDInputViewController * idController = [storyboard instantiateViewControllerWithIdentifier:@"idController"];
        idController.delegate = self;
        [idController setTitle:kPBHostText];
        [self.navigationController pushViewController:idController animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 2){
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        IDInputViewController * idController = [storyboard instantiateViewControllerWithIdentifier:@"idController"];
        idController.delegate = self;
        [idController setTitle:kPBAccountIDText];
        idController.idInputText.text = self.accountID;
        [self.navigationController pushViewController:idController animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 3){
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
    if(section != 3)
        return 40.0f;
    else
        return 50.0f;
}

- (UITableViewCell *) configureGeneralInfoSection:(UITableView *) tableView withIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        static NSString *labelAccessoryCell = @"LabelAccessoryCell";
        
        LabelAccessoryCell *cell = (LabelAccessoryCell *)[tableView dequeueReusableCellWithIdentifier:labelAccessoryCell];
        
        if(cell != nil){
            if([[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey] isEqualToString:@""]){
                self.chosenAdFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey];
            }
            cell.lblTitle.text = kAdFormatText;
            cell.lblSelectedContent.enabled = NO;
            cell.lblSelectedContent.text = self.chosenAdFormat;
            
            if([self.chosenAdFormat isEqualToString:kInterstitialString]){
                self.isInterstitial = YES;
            } else {
                self.isInterstitial = NO;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                
                if(self.chosenAdFormat != nil && [self.chosenAdFormat isEqualToString:@"Native"]){
                    cell.lblSelectedContent.text = @"1x1";
                    self.chosenAdSize = @"1x1";
                } else {
                
                if(self.chosenAdSize == nil || [self.chosenAdSize isEqualToString:@""]){
                
                    if([[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey] isEqualToString:@""]){
                        self.chosenAdSize = [[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey];
                    }
                    if ([self.chosenAdSize isEqualToString:@"Interstitial"] || self.chosenAdSize == nil) {
                        self.chosenAdSize = @"300x250";
                    }
                }
                cell.lblSelectedContent.text = self.chosenAdSize;
                [cell.lblSelectedContent setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
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
            NSArray *adServerItems = @[kAdServerDFP];
            [cell.segmentControl setTitle:adServerItems[0] forSegmentAtIndex:0];
            [cell.segmentControl addTarget:self action:@selector(adServerChanged:) forControlEvents:UIControlEventValueChanged];
            
            [cell.segmentControl setSelectedSegmentIndex:0];
            // TODO: restore from defaults if new ad server is added
//            if([[NSUserDefaults standardUserDefaults] objectForKey:kAdServerNameKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kAdServerNameKey] isEqualToString:@""]){
//            }
            
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
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:kBidPriceKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kBidPriceKey] isEqualToString:@""]){
                    
                    self.bidPrice = [NSString stringWithFormat:@"$%@", [[NSUserDefaults standardUserDefaults] objectForKey:kBidPriceKey]];
                    
                    cell.lblSelectedContent.text = self.bidPrice;
                }
                
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
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey] isEqualToString:@""]){
                    cell.lblId.text = [[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey];
                    
                    self.adUnitID = cell.lblId.text;
                }
                
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
        static NSString *labelAccessoryCell = @"LabelAccessoryCell";
        
        LabelAccessoryCell *cell = (LabelAccessoryCell *)[tableView dequeueReusableCellWithIdentifier:labelAccessoryCell];
        
        if(cell != nil){
            if([[NSUserDefaults standardUserDefaults] objectForKey:kPBHostKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kPBHostKey] isEqualToString:@""]){
                if([[[NSUserDefaults standardUserDefaults] objectForKey:kPBHostKey] isEqualToString: kPrebidHostAppnexus]){
                    cell.lblSelectedContent.text = kPrebidHostAppnexus;
                } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:kPBHostKey] isEqualToString: kPrebidHostRubicon]){
                    cell.lblSelectedContent.text = kPrebidHostRubicon;
                } else {
                    cell.lblSelectedContent.text = kPrebidHostCustom;
                }
            }
            cell.lblTitle.text = @"Host";
            cell.lblSelectedContent.enabled = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    } else if(indexPath.row == 1){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
           
                cell.lblIDText.text = kPBCustomHostText;
                if (self.customHost == nil || [self.customHost isEqualToString:@""]) {
                    cell.lblId.text = @"ie: https://ib.adnxs.com/openrtb2/prebid";
                    [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                    [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                    
                    if([[NSUserDefaults standardUserDefaults] objectForKey:kPBCustomHostKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kPBCustomHostKey] isEqualToString:@""]){
                        cell.lblId.text = [[NSUserDefaults standardUserDefaults] objectForKey:kPBCustomHostKey];
                        
                        self.customHost = cell.lblId.text;
                    }
                    
                } else {
                    cell.lblId.text = self.customHost;
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
            cell.lblIDText.text = kPBAccountIDText;
            if (self.accountID == nil || [self.accountID isEqualToString:@""]) {
                cell.lblId.text = @"ie: 00000-0000-0000-00000-00000-00000";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:kPBAccountKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kPBAccountKey] isEqualToString:@""]){
                    cell.lblId.text = [[NSUserDefaults standardUserDefaults] objectForKey:kPBAccountKey];
                    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kPBAccountKey]);
                    self.accountID = cell.lblId.text;
                }
                
            } else {
                cell.lblId.text = self.accountID;
                NSLog(@"%@", self.accountID);
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }
    else if (indexPath.row == 3){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = kPBConfigIDText;
            if (self.configID == nil || [self.configID isEqualToString:@""]) {
                cell.lblId.text = @"ie: 00000-0000-0000-00000-00000-00000";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                
                if([[NSUserDefaults standardUserDefaults] objectForKey:kPBConfigKey] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:kPBConfigKey] isEqualToString:@""]){
                    cell.lblId.text = [[NSUserDefaults standardUserDefaults] objectForKey:kPBConfigKey];
                    
                    self.configID = cell.lblId.text;
                }
                
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
    
    NSArray *bidPriceArray = [self.bidPrice componentsSeparatedByString:@"$"];
    [[NSUserDefaults standardUserDefaults] setObject:bidPriceArray[1] forKey:kBidPriceKey];
}

-(NSString *) currencyFormatting :(NSString *) currency {
    
    
    NSNumberFormatter *inputFormatter = [[NSNumberFormatter alloc] init];
    inputFormatter.numberStyle = NSNumberFormatterCurrencyAccountingStyle;
    inputFormatter.currencySymbol = @"$";
    inputFormatter.maximumFractionDigits = 2;
    inputFormatter.minimumFractionDigits = 2;
    
    NSError *error = NULL;
    NSRegularExpression *expPattern = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *newCurrency = [expPattern stringByReplacingMatchesInString:currency options:0 range:NSMakeRange(0, currency.length) withTemplate:@""];
    
    double doubleValue = newCurrency.doubleValue;
    
    NSNumber *inputNumber = [NSNumber numberWithDouble:doubleValue/100];

    if([inputNumber isEqual:0])
        return @"";
    else
        return [inputFormatter stringFromNumber:inputNumber];
}

-(void) adServerChanged:(id) sender {
    UISegmentedControl *adTypeSegment = (UISegmentedControl *) sender;
    
    if(adTypeSegment.selectedSegmentIndex == 1){
        if([self.chosenAdFormat isEqualToString:kNativeString]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AdFormat not supported" message:@"MoPub doesnt support native styles." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* noButton = [UIAlertAction
            actionWithTitle:@"Ok"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
                //Handle no, thanks button
                adTypeSegment.selectedSegmentIndex = 0;
            }];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else if(adTypeSegment.selectedSegmentIndex == 0){
        [[NSUserDefaults standardUserDefaults] setObject:kAdServerDFP forKey:kAdServerNameKey];
    }
    
}


-(void) sendSelectedAdSize:(NSString *)adSize {
    if(adSize != nil && ![adSize isEqualToString:@""]){
        self.chosenAdSize = adSize;
        [self.tableView reloadData];
    }
}

-(void) sendSelectedAdFormat:(NSString *)adFormat {
    if(adFormat != nil && ![adFormat isEqualToString:@""]){
        [[NSUserDefaults standardUserDefaults] setObject:adFormat forKey:kAdFormatNameKey];
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
    } else if([idLabel isEqualToString:kPBHostText]){
        self.customHost = idString;
        [[NSUserDefaults standardUserDefaults] setObject:self.customHost forKey:kCustomPrebidServerEndpoint];
    }
    [self.tableView reloadData];
    
}

-(void) didPressNext:(id) sender {
    
    ToolReachability *reachability = [ToolReachability reachabilityForInternetConnection];
    ToolNetworkStatus status = [reachability currentReachabilityStatus];
    NSUInteger connectionType = 0;
    switch (status) {
        case ToolNetworkStatusReachableViaWiFi:
            connectionType = 1;
            break;
        case ToolNetworkStatusReachableViaWWAN:
            connectionType = 2;
            break;
        default:
            connectionType = 0;
            break;
    }
    
   if (connectionType == 0) {
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Connection" message:@"No network available." preferredStyle:UIAlertControllerStyleAlert];
       
       UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction
                                                                                                                 *action){[self.navigationController popViewControllerAnimated:YES];}];
       [alert addAction:cancel];
       [self presentViewController:alert animated:YES completion:nil];
       
   } else {
    
       [[NSUserDefaults standardUserDefaults] synchronize];
       [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kAdServerResponseCreative];
       NSString * storyboardName = @"Main";
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
       TestSummaryViewController * summaryViewController = [storyboard instantiateViewControllerWithIdentifier:@"summaryViewController"];
    
       [self.navigationController pushViewController:summaryViewController animated:YES];
   }
}

- (NSString *) removeSpacesAndNewLines: (NSString *) original
{
    if (original != nil) {
        NSString *trimmedString = [original stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return trimmedString;
    }
    return nil;
}

-(BOOL) checkIfTestButtonCanBeDisabled {
    
    if(self.isInterstitial == FALSE && (self.chosenAdSize == nil || [self.chosenAdSize isEqualToString:@""]))
        return FALSE;
    
    if(self.adUnitID == nil || ([self.adUnitID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0))
        return FALSE;
    if(self.accountID == nil || ([self.accountID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0))
        return FALSE;
    
    if(self.configID == nil || ([self.configID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0))
        return FALSE;
    
    if(!self.hideCustomHost &&(self.customHost == nil || ([self.customHost stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)))
        return FALSE;
    
    if([self.chosenAdFormat isEqualToString:kNativeString]){
        NativeRequest *request = ((AppDelegate*)[UIApplication sharedApplication].delegate).nativeRequest;
        
        if(request == nil)
            return FALSE;
    }
    
    if(self.bidPrice == nil || (self.bidPrice.length <= 0))
        return FALSE;
    
    return TRUE;
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(row == 2){
        [[NSUserDefaults standardUserDefaults] setObject:kPrebidHostCustom forKey:kPBHostKey];
        self.hideCustomHost = NO;
    } else if(row == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:kPrebidHostRubicon forKey:kPBHostKey];
        self.hideCustomHost = YES;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:kPrebidHostAppnexus forKey:kPBHostKey];
        self.hideCustomHost = YES;
    }
    self.pickerView.hidden = YES;
    [self.tableView reloadData];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
     NSArray *adServerItems = @[kPrebidHostAppnexus, kPrebidHostRubicon, kPrebidHostCustom];
    return adServerItems[row];
}

@end
