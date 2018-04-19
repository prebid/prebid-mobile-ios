//
//  SettingsViewController.m
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 24/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

#import "SettingsViewController.h"
#import "ListViewController.h"
#import "ActionSheetPicker.h"
#import "PBVSharedConstants.h"
#import "LineItemAdsViewController.h"
#import "QRCodeReaderViewController.h"

NSString *__nonnull const kNextButtonText = @"Start Validation";




NSString *__nonnull const kErrorMessageTitle = @"Oops...";

CGFloat const kLabelHeight = 80.0f;

@interface StyledCell : UITableViewCell

@end

@implementation StyledCell

- (id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

@end

@interface ScanButton: UIButton
@property id userData;
@end

@implementation ScanButton
@synthesize userData;
@end

@interface SettingsViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,QRCodeReaderDelegate>

@property NSArray *adServers;
@property NSArray *adFormats;
@property NSArray *adSizes;

@property (nonatomic, strong) UITableView *userInputTableView;
@property NSDictionary *tableViewDictionaryItems;
@property NSArray *sectionTitles;
@property NSDictionary *initialDetailTextValues;

@property NSString *adServer;
@property NSString *adFormat;
@property NSString *adSize;
@property NSString *adUnitId;
@property NSString *bidPrice;

@property NSString *accountID;
@property NSString *configID;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    self.navigationController.navigationBar.translucent = NO;
    
    _userInputTableView = [[UITableView alloc] init];
    _userInputTableView.frame = self.view.frame;
    _userInputTableView.dataSource = self;
    _userInputTableView.delegate = self;

    _userInputTableView.backgroundColor = [UIColor whiteColor];
    [_userInputTableView setSeparatorColor:[UIColor darkGrayColor]];
    [_userInputTableView registerClass:[StyledCell class] forCellReuseIdentifier:@"Cell"];
    
    if ([_userInputTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        _userInputTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:_userInputTableView];
    
    
    _tableViewDictionaryItems = @{@"General" : @[kAdFormatLabelText, kAdSizeLabelText],
                                  @"AD Server" :@[kAdServerLabelText, kAdUnitIdText, kBidPriceText],
                                  @"PreBid Server" : @[kPBAccountIDText, kPBConfigIDText]
                                  };
    
    //_tableViewItems = @[kAdFormatLabelText, kAdSizeLabelText, kAdServerLabelText, kAdUnitIdText, kBidPriceText, kPBAccountID, kPBConfigID];
    
    
    _sectionTitles = @[@"General", @"AD Server", @"PreBid Server"];
    
    _adServers = @[kMoPubString, kDFPString];
    _adFormats = @[kBannerString, kInterstitialString];
    _adSizes = @[kBannerSizeString, kMediumRectangleSizeString, kInterstitialSizeString];

    _adServer = [[NSUserDefaults standardUserDefaults] objectForKey:kAdServerNameKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdServerNameKey] : self.adServers[0];
    _adFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdFormatNameKey] : self.adFormats[0];
    _adSize = [[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdSizeKey] : self.adSizes[0];
    _adUnitId = [[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kAdUnitIdKey] : @"";
    
    _accountID = [[NSUserDefaults standardUserDefaults] objectForKey:kPBAccountKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kPBAccountKey] : @"";
    _configID = [[NSUserDefaults standardUserDefaults] objectForKey:kPBConfigKey] ? [[NSUserDefaults standardUserDefaults] objectForKey:kPBConfigKey] : @"";
    
    id bidPriceInitialArray = [[NSUserDefaults standardUserDefaults] objectForKey:kBidPriceKey];
    if ([bidPriceInitialArray isKindOfClass:[NSArray class]]) {
        _bidPrice = [bidPriceInitialArray componentsJoinedByString:@","];
    } else {
        _bidPrice = @"";
    }
    
    _initialDetailTextValues = @{@"General" : @[_adFormat, _adSize],
                                  @"AD Server" :@[_adServer, _adUnitId, _bidPrice],
                                  @"PreBid Server" : @[_accountID, _configID]
                                  };
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    StyledCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[StyledCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if ((indexPath.section == 1 && indexPath.row == 1) || indexPath.section == 2) {
        ScanButton *scan = [ScanButton buttonWithType:UIButtonTypeRoundedRect];
        [scan setFrame:CGRectMake(0, 0, 40, 40)];
        [scan setTitle:@"Scan" forState:UIControlStateNormal];
        [scan setUserData:indexPath];
        [scan addTarget:self action:@selector(scanPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = scan;
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionObjects = [self.tableViewDictionaryItems objectForKey:sectionTitle];
    NSString *objectContent = [sectionObjects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = objectContent;
    NSArray *sectionArrayObjects = [self.initialDetailTextValues objectForKey:sectionTitle];
    cell.detailTextLabel.text = sectionArrayObjects[indexPath.row];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - QRCode Scanner
- (void)scanPressed:(id)sender{
    NSIndexPath *currentIndexPath = (NSIndexPath *)[(ScanButton *) sender userData];
    // uses code from this lib: https://github.com/yannickl/QRCodeReaderViewController
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    QRCodeReaderViewController *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    [vc setCompletionWithBlock:^(NSString * _Nullable resultAsString) {
        NSLog(@"Scanned result is : %@", resultAsString);
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cell = [_userInputTableView cellForRowAtIndexPath:currentIndexPath];
            cell.detailTextLabel.text = resultAsString;
        });
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [reader dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionTitles count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0){
        return 2;
    }
    else if (section == 1){
        return 3;
    } else if(section == 2){
        return 2;
    }
    
    return 1;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    if ([cellText isEqualToString:kAdServerLabelText]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select an Ad Server"
                                                rows:self.adServers
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               cell.detailTextLabel.text = selectedValue;
                                               self.adServer = selectedValue;
                                               [cell setSelected:NO];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             [cell setSelected:NO];
                                         }
                                              origin:tableView];
    } else if ([cellText isEqualToString:kAdFormatLabelText]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select an Ad Format"
                                                rows:self.adFormats
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               cell.detailTextLabel.text = selectedValue;
                                               self.adFormat = selectedValue;
                                               [cell setSelected:NO];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             [cell setSelected:NO];
                                         }
                                              origin:tableView];
    } else if ([cellText isEqualToString:kAdSizeLabelText]) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select an Ad Size"
                                                rows:self.adSizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               cell.detailTextLabel.text = selectedValue;
                                               self.adSize = selectedValue;
                                               [cell setSelected:NO];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             [cell setSelected:NO];
                                         }
                                              origin:tableView];
    } else if ([cellText isEqualToString:kAdUnitIdText]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter your Ad Unit ID"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.adUnitId;
            textField.placeholder = @"Ad Unit ID";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
            [textField addTarget:self
                          action:@selector(adUnitIdTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            [cell setSelected:NO];
        }];
    } else if ([cellText isEqualToString:kBidPriceText]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter one or more bid price in dollars"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.bidPrice;
            textField.placeholder = @"ex. 0.50,1.00,2.50";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
            [textField addTarget:self
                          action:@selector(bidPriceTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            [cell setSelected:NO];
        }];
    } else if ([cellText isEqualToString:kPBAccountIDText]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter Prebid AccountID"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.accountID;
            textField.placeholder = @"Prebid Account ID";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
            [textField addTarget:self
                          action:@selector(accountIDTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            [cell setSelected:NO];
        }];
    } else if ([cellText isEqualToString:kPBConfigIDText]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter Prebid ConfigID"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = self.configID;
            textField.placeholder = @"Prebid Config ID";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
            [textField addTarget:self
                          action:@selector(configIdTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:^{
            [cell setSelected:NO];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 2){
    return kLabelHeight;
    }
    else {
        return 20.0f;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if(section == 2){
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:kNextButtonText forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, kLabelHeight);
    [nextButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [nextButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [nextButton addTarget:self action:@selector(didPressNext:) forControlEvents:UIControlEventTouchUpInside];
    return nextButton;
    } else
    {
        return nil;
    }
}

// Responders to user actions - text input and button click
- (void)bidPriceTextFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self.userInputTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    cell.detailTextLabel.text = textField.text;
    self.bidPrice = textField.text;
}

- (void)adUnitIdTextFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self.userInputTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.detailTextLabel.text = textField.text;
    self.adUnitId = textField.text;
}

- (void)accountIDTextFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self.userInputTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    cell.detailTextLabel.text = textField.text;
    self.accountID = textField.text;
}

- (void)configIdTextFieldDidChange:(UITextField *)textField {
    UITableViewCell *cell = [self.userInputTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    cell.detailTextLabel.text = textField.text;
    self.configID = textField.text;
}

- (void)didPressNext:(id)sender {
    [self verifyInput];
    
    ListViewController *listViewController = [[ListViewController alloc] init];
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)verifyInput {
    UIAlertController *alertController = nil;
    if ([self.adServer isEqualToString:kDFPString] && [self.adFormat isEqualToString:kInterstitialString]) {
        alertController = [UIAlertController alertControllerWithTitle:kErrorMessageTitle message:@"We currently do not support DFP Interstitial on the Test App. Please choose a different ad server or format." preferredStyle:UIAlertControllerStyleAlert];
    }
    if ([self.adFormat isEqualToString:kInterstitialString] && ([self.adSize isEqualToString:kInterstitialSizeString] == NO)) {
        alertController = [UIAlertController alertControllerWithTitle:kErrorMessageTitle message:@"Interstitial must be of size 320x480. Please update ad size in the picker." preferredStyle:UIAlertControllerStyleAlert];
    }

    if (alertController) {
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:self.adServer forKey:kAdServerNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.adFormat forKey:kAdFormatNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.adSize forKey:kAdSizeKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.adUnitId forKey:kAdUnitIdKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.accountID forKey:kPBAccountKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.configID forKey:kPBConfigKey];
    
    
    NSArray *bidPrices = [self.bidPrice componentsSeparatedByString:@","];
    [[NSUserDefaults standardUserDefaults] setObject:bidPrices forKey:kBidPriceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
