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

#import <Foundation/Foundation.h>
#import "DemandValidatorViewController.h"
#import "DemandValidator.h"
#import "DemandHeaderCell.h"
#import "DemandViewCell.h"

NSString *__nonnull const kCellString = @"demandCell";
NSString *__nonnull const kHeaderString = @"demandHeader";

@interface DemandValidatorViewController()<UITableViewDataSource, UITableViewDelegate>
@property DemandValidator *validator;
@property UIViewController *first;
@property UIViewController *second;
@property UITextView *requestText;
@property UITextView *responseText;

@end

@implementation DemandValidatorViewController
- (instancetype)initWithValidator:(DemandValidator *) validator
{
    self = [super init];
    if (self) {
        _validator = validator;
        NSLog(@"%@", _validator.testResults);
        
        _resultsDictionary = _validator.testResults;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Real-Time Demand";
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DemandViewCell" bundle:nil] forCellReuseIdentifier:kCellString];
    [self.tableView registerNib:[UINib nibWithNibName:@"DemandHeaderCell" bundle:nil] forCellReuseIdentifier:kHeaderString];
    
    [self.tableView reloadData];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultsDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DemandHeaderCell *cell = (DemandHeaderCell *)[tableView dequeueReusableCellWithIdentifier:kHeaderString];
    
    if(cell == nil)
        return nil;
    
    cell.lblRightHeader.text = @"Request & Response";
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 130.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
}

// Helper function
- (NSString *) prettyJson: (NSString *) jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject == nil) {
        return jsonString;
    } else {
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        NSString *prettyPrintedJson = [NSString stringWithUTF8String:[prettyJsonData bytes]];
        return prettyPrintedJson;
    }
}



@end


