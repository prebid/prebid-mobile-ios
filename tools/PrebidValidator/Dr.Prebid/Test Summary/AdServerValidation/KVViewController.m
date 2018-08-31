
#import "KVViewController.h"
#import "ColorTool.h"

@interface KVViewController () <UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UITableViewDataSource,
                                UITableViewDelegate>
@property (strong) NSDictionary *keyWordsDictionary;
@property NSArray *keys;
@property NSString *requestString;
@property NSString *requestURL;
@property NSDictionary *queryStringDict;
@property NSArray *queryStringKeys;
@property UICollectionView *collectionView;
@property UITableView *tableView;
@end

@implementation KVViewController

- (instancetype)initWithRequestString:(NSString *)requestString
{
    self = [super init];
    if (self) {
        self.requestString = requestString;
        if (self.requestString != nil) {
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
            NSMutableDictionary *keywordsDict = [[NSMutableDictionary alloc] init];
            if ([self.requestURL containsString:@"ads.mopub.com/m/ad"]) {
                NSString *keywords = [self.queryStringDict objectForKey:@"q"];
                NSArray *keywordsArray = [keywords componentsSeparatedByString:@","];
                for (NSString *keyword in keywordsArray) {
                    if (![keyword isEqualToString:@""]) {
                        NSArray *keywordPair = [keyword componentsSeparatedByString:@":"];
                        [keywordsDict setObject:keywordPair[1] forKey:keywordPair[0]];
                    }
                }
            } else {
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
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Key-Value Targeting";
    self.view.backgroundColor = [ColorTool prebidGrey];
    NSArray *itemArray = @[@"Prebid Key-Value Pairs", @"Ad ServerRequet"];
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:itemArray];
    control.selectedSegmentIndex = 0;
    [control addTarget:self action:@selector(controlSwitch:) forControlEvents:UIControlEventValueChanged];
    control.frame = CGRectMake(20, 80, self.view.frame.size.width -40, 50);
    [self.view addSubview:control];
    [self setupUICollectionView];
    [self setupUITableView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.tableView];
}

- (void) controlSwitch:(UISegmentedControl *)segment
{
    if (segment.selectedSegmentIndex == 0) {
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
    }
    
}
#pragma mark UITableView
- (void) setupUITableView
{
    if (self.tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, self.view.frame.size.height-140)];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
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
    return self.queryStringDict.allKeys.count + 1;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdenitifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIndetifier"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@?", self.requestURL];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@=%@&", self.queryStringKeys[indexPath.row -1], [self.queryStringDict objectForKey:self.queryStringKeys[indexPath.row -1]] ];
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
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, 200) collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
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
    CGSize size = [self getSizeForIndex:indexPath];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    if (indexPath.row % 3 == 0) {
        textLabel.text = self.keys[indexPath.section];
        textLabel.textColor = [ColorTool prebidBlue];
    } else if (indexPath.row %3 == 1) {
        textLabel.text = @" = ";
    } else {
        textLabel.text = [self.keyWordsDictionary objectForKey:self.keys[indexPath.section]];
        textLabel.textColor = [ColorTool prebidOrange];
    }
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
        width = 100;
    } else if (indexPath.row %3 == 1) {
        width = 20;
    } else {
        width = self.view.frame.size.width - 120;
    }
    return CGSizeMake(width, 50);
}



@end
