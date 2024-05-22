//
//  KeyValueController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 1/7/19.
//  Copyright © 2019 Prebid. All rights reserved.
//

#import "KeyValueController.h"
#import "ColorTool.h"
#import "PBVSharedConstants.h"

@interface KeyValueController () <UICollectionViewDelegate,
UICollectionViewDataSource,
UITableViewDataSource,
UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCntrl;

@property (strong) NSDictionary *keyWordsDictionary;
@property NSString *postData;
@property NSArray *keys;
@property NSString *requestURL;
@property NSDictionary *queryStringDict;
@property NSArray *queryStringKeys;
@property UICollectionView *collectionView;
@property UITableView *tableView;
@property CGFloat yAxis;

@end

@implementation KeyValueController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self processData];
    self.title = @"Key-Value Targeting";
    self.view.backgroundColor = [ColorTool prebidGrey];
    [self.segmentCntrl setTitle:@"Prebid Key-Value Pairs" forSegmentAtIndex:0];
    [self.segmentCntrl setTitle:@"Ad Server Request" forSegmentAtIndex:1];
    
    self.segmentCntrl.tintColor = [ColorTool prebidBlue];
    self.segmentCntrl.backgroundColor = [UIColor whiteColor];
    self.segmentCntrl.layer.cornerRadius = 5.0;
    [self.segmentCntrl addTarget:self action:@selector(controlSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.yAxis = 125.0;
    if([self checkSafeAreaInsets])
        self.yAxis = 150.0;
    
    [self setupUICollectionView];
    [self setupUITableView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [ColorTool prebidGrey];
    
    
}

- (void) controlSwitch:(UISegmentedControl *)segment
{
    if (segment.selectedSegmentIndex == 0) {
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    
}

-(void) processData {
    
    if([self.requestString isEqualToString:@""] || [self.postDataString isEqualToString:@""])
        return;
    
    self.postData = self.postDataString;
    
        if (self.requestString != nil) {
            NSMutableDictionary *keywordsDict = [[NSMutableDictionary alloc] init];
            if ([self.requestString containsString:@"ads.mopub.com/m/ad"]) {
                self.requestURL = self.requestString;
                NSData *data = [self.postDataString dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *keywords = json[@"q"];
                NSArray *keywordsArray = [keywords componentsSeparatedByString:@","];
                for (NSString *keyword in keywordsArray) {
                    if ([keyword containsString: @":"]) {
                        NSArray *keywordPair = [keyword componentsSeparatedByString:@":"];
                        [keywordsDict setObject:keywordPair[1] forKey:keywordPair[0]];
                    }
                }
            } else {
                NSArray *requestStringArray = [self.requestString componentsSeparatedByString:@"?"];
                self.requestURL = requestStringArray[0];
                NSMutableDictionary *qsDict = [[NSMutableDictionary alloc] init];
                NSArray *queryStringArray = [requestStringArray[1] componentsSeparatedByString:@"&"];
                for (NSString *queryStringPair in queryStringArray) {
                    NSArray *queryStringPairArray = [queryStringPair componentsSeparatedByString:@"="];
                    [qsDict setObject:queryStringPairArray[1] forKey:queryStringPairArray[0]];
                }
                self.queryStringDict = [qsDict copy];
                self.queryStringKeys = [self.queryStringDict.allKeys copy];
                NSString *keywords = [self.queryStringDict objectForKey:@"cust_params"];
                NSArray *keywordsArray = [keywords componentsSeparatedByString:@"%26"];
                for (NSString *keyword in keywordsArray) {
                    if (![keyword isEqualToString:@""]) {
                        NSArray *keywordPair = [keyword componentsSeparatedByString:@"%3D"];
                        [keywordsDict setObject:keywordPair[1] forKey:keywordPair[0]];
                    }
                }
            }
            self.keyWordsDictionary = [keywordsDict copy];
            self.keys = [self.keyWordsDictionary.allKeys copy];
        }
    
}
#pragma mark UITableView
- (void) setupUITableView
{
    if (self.tableView == nil) {
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yAxis, self.view.frame.size.width, self.view.frame.size.height)];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorColor = [UIColor clearColor];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
        self.tableView.hidden = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.requestString containsString:@"ads.mopub.com/m/ad"]){
        return 2;
    } else {
        return self.queryStringDict.allKeys.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdenitifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIndetifier"];
    }
    [cell.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    [cell.textLabel setTextColor:[ColorTool prebidCodeSnippetGrey]];
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@?", self.requestURL];
    } else {
        if ([self.requestString containsString:@"ads.mopub.com/m/ad"])  {
            cell.textLabel.text = self.postData;
            cell.textLabel.numberOfLines = 0;
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@=%@&", self.queryStringKeys[indexPath.row -1], [self.queryStringDict objectForKey:self.queryStringKeys[indexPath.row -1]] ];
            cell.textLabel.numberOfLines = 0;
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}
#pragma mark UICollectionView

- (void) setupUICollectionView
{
    if (self.collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        float height = self.keys.count * 50;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.yAxis, self.view.frame.size.width, height) collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = YES;
        self.collectionView.alwaysBounceVertical = YES;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        self.collectionView.hidden = NO;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.keys.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    CGSize size = [self getSizeForIndex:indexPath];
    UILabel *textLabel = [[UILabel alloc] init];
    [textLabel setFont:[UIFont systemFontOfSize:17.0]];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    if (indexPath.row % 3 == 0) {
        textLabel.frame = CGRectMake(20, 0, size.width -40, size.height);
        textLabel.text = self.keys[indexPath.section];
        textLabel.textColor = [ColorTool prebidBlue];
    } else if (indexPath.row %3 == 1) {
        textLabel.frame = CGRectMake(0, 0, size.width, size.height);
        textLabel.text = @" = ";
    } else {
        textLabel.frame = CGRectMake(20, 0, size.width-40, size.height);
        textLabel.text = [self.keyWordsDictionary objectForKey:self.keys[indexPath.section]];
        textLabel.textColor = [ColorTool prebidOrange];
    }
    textLabel.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:textLabel];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getSizeForIndex:indexPath];
}

- (CGSize) getSizeForIndex: (NSIndexPath *) indexPath
{
    CGFloat width = 0;
    if (indexPath.row % 3 == 0) {
        width = 140;
    } else if (indexPath.row %3 == 1) {
        width = 20;
    } else {
        width = self.view.frame.size.width - 160;
    }
    return CGSizeMake(width, 50);
}

// Helper function
- (void) prettyJson: (NSString *) jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject == nil) {
        self.postData = jsonString;
    } else {
        if([jsonObject isKindOfClass:[NSDictionary class]]){
            self.postData = [(NSDictionary *) jsonObject description];
        } else {
            NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            NSString *prettyPrintedJson = [[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding];
            self.postData = prettyPrintedJson;
        }
        
    }
}

-(BOOL) checkSafeAreaInsets {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat topPadding = window.safeAreaInsets.top;
        
        if(topPadding > 0)
            return true;
        
    }

    return false;
}


@end
