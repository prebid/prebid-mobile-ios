/*   Copyright 2019-2022 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "ExamplesViewController.h"
#import "SettingsViewController.h"
#import "AdFormat.h"
#import "AdFormatDescriptor.h"
#import "IntegrationKind.h"
#import "IntegrationKindDescriptor.h"
#import "IntegrationCase.h"
#import "IntegrationCaseManager.h"

NSString * const cellID = @"exampleCell";

@interface ExamplesViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *integrationKindPicker;
@property (weak, nonatomic) IBOutlet UIButton *adFormatPicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) IntegrationKind currentIntegrationKind;
@property (nonatomic) AdFormat currentAdFormat;
@property (nonatomic) NSString *filterText;
@property (nonatomic) NSArray<IntegrationCase *> *displayedCases;

@end

@implementation ExamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.displayedCases = IntegrationCaseManager.allCases;
    
    [self setupPickers];
}

- (IBAction)onSettingsPressed:(id)sender {
    SettingsViewController * settingsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    settingsViewController.title = @"Settings";
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

// MARK: - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.displayedCases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    UIListContentConfiguration *configuration = cell.defaultContentConfiguration;
    configuration.text = self.displayedCases[indexPath.row].title;
    cell.contentConfiguration = configuration;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IntegrationCase * testCase = self.displayedCases[indexPath.row];
    
    UIViewController * viewController = testCase.configurationClosure();
    viewController.view.backgroundColor = [UIColor whiteColor];
    viewController.title = testCase.title;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

// MARK: - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.filterText = searchBar.text ? : @"";
    [self filterTestCases];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.filterText = searchBar.text ? : @"";
    [self filterTestCases];
    [searchBar endEditing:YES];
}

- (void)filterTestCases {
    self.displayedCases = [[NSMutableArray alloc] init];
    
    self.displayedCases = [IntegrationCaseManager.allCases filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IntegrationCase * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return self.filterText.length == 0 || [evaluatedObject.title rangeOfString:self.filterText options:NSCaseInsensitiveSearch].length > 0;
    }]];
    
    self.displayedCases = [self.displayedCases filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IntegrationCase * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return self.currentIntegrationKind == IntegrationKindAll ? true : evaluatedObject.integrationKind == self.currentIntegrationKind;
    }]];
    
    self.displayedCases = [self.displayedCases filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IntegrationCase * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return self.currentAdFormat == AdFormatAll ? true : evaluatedObject.adFormat == self.currentAdFormat;
    }]];
    
    [self.tableView reloadData];
}

- (void)setupPickers {
    UIAction * allIntegrationKindsAction = [UIAction actionWithTitle:@"All" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.currentIntegrationKind = IntegrationKindAll;
        [self filterTestCases];
    }];
    
    NSMutableArray<UIAction *> * integrationKindActions = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < IntegrationKindAll; ++i) {
        [integrationKindActions addObject:[UIAction actionWithTitle:[IntegrationKindDescriptor getDescriptionForIntegrationKind:(IntegrationKind)i] image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.currentIntegrationKind = (IntegrationKind)i;
            [self filterTestCases];
        }]];
    }
    
    [integrationKindActions addObject:allIntegrationKindsAction];
    
    self.integrationKindPicker.showsMenuAsPrimaryAction = YES;
    self.integrationKindPicker.changesSelectionAsPrimaryAction = YES;
    
    integrationKindActions.firstObject.state = UIMenuElementStateOn;
    
    UIMenu *integrationKindMenu = [UIMenu menuWithChildren:integrationKindActions];
    self.integrationKindPicker.menu = integrationKindMenu;
    
    UIAction * allAdFormatsAction = [UIAction actionWithTitle:@"All" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.currentAdFormat = AdFormatAll;
        [self filterTestCases];
    }];
    
    NSMutableArray<UIAction *> * adFormatsActions = [[NSMutableArray alloc] initWithObjects:allAdFormatsAction, nil];
    
    for (int i = 0; i < AdFormatAll; ++i) {
        [adFormatsActions addObject:[UIAction actionWithTitle:[AdFormatDescriptor getDescriptionForAdFormat:(AdFormat)i] image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            self.currentAdFormat = (AdFormat)i;
            [self filterTestCases];
        }]];
    }
    
    self.adFormatPicker.showsMenuAsPrimaryAction = YES;
    self.adFormatPicker.changesSelectionAsPrimaryAction = YES;
    
    adFormatsActions.firstObject.state = UIMenuElementStateOn;
    
    UIMenu *adFormatMenu = [UIMenu menuWithChildren:adFormatsActions];
    self.adFormatPicker.menu = adFormatMenu;
    
    self.currentIntegrationKind = IntegrationKindGAMOriginal;
    self.currentAdFormat = AdFormatAll;
    [self filterTestCases];
}

@end
