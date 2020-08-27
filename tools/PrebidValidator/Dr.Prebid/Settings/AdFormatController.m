/*
 *    Copyright 2020 Prebid.org, Inc.
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

#import <Foundation/Foundation.h>
#import "AdFormatController.h"
#import "PBVSharedConstants.h"

@interface AdFormatController () <UITableViewDelegate, UITableViewDataSource>
@property NSArray *formatArray;
@property NSString *selectedFormat;
@end

@implementation AdFormatController
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.target = self;
    doneButton.action = @selector(doneAction:);
    doneButton.title = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.hidesBackButton = YES;
    self.formatArray= @[kBannerString, kInterstitialString, kNativeString, kVideoString];
    UITableView *tableView = [[UITableView alloc] init];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _formatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    cell.textLabel.text = _formatArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    if(self.settingsAdFormat != nil &&  [self.settingsAdFormat isEqualToString:cell.textLabel.text] ){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    for (UITableViewCell *cell in [tableView visibleCells]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedFormat = cell.textLabel.text;
    
    NSLog(@"cell text: %@", cell.textLabel.text);
    
}

-(void) doneAction :(id) sender {
    
    [self.delegate sendSelectedAdFormat:self.selectedFormat];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
