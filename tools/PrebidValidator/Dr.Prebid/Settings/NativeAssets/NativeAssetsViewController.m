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

#import "NativeAssetsViewController.h"
#import "LabelAccessoryCell.h"
#import "ImageCell.h"
#import "IdCell.h"
#import "AssetsViewController.h"
#import "PBVSharedConstants.h"
#import "AppDelegate.h"

@interface NativeAssetsViewController () <UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource,AssetsProtocol>

@property (nonatomic, strong) NSArray *NativeAssets;

@property (nonatomic, strong) NativeRequest *nativeRequest;

@property (nonatomic, strong) NSString *dataAssets;
@property (nonatomic, strong) NSString *titleLength;
@property (nonatomic, strong) NSString *eventType;

@end

@implementation NativeAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Native Assets";
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    //create native ad with dummy config id. We can update the actual later
    self.nativeRequest = [[NativeRequest alloc] initWithConfigId:@"123"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(btnSavePressed:)];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0]];
    
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    
    [self.tableView reloadData];
}


#pragma mark - Actions

-(void) btnSavePressed :(id)sender {
    
    if(self.nativeRequest){
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        ImageCell *mainImageCell = [self.tableView cellForRowAtIndexPath:path];
        
        NativeAssetImage *mainImage = [[NativeAssetImage alloc] initWithMinimumWidth:(int)mainImageCell.txtMinWidth.text minimumHeight:[mainImageCell.txtMinHeight.text intValue] required:YES];
        mainImage.type = ImageAsset.Main;
        
        
        ImageCell *iconImageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        
        NativeAssetImage *iconImage = [[NativeAssetImage alloc] initWithMinimumWidth:[iconImageCell.txtMinWidth.text intValue] minimumHeight:[iconImageCell.txtMinHeight.text intValue] required:YES];
        iconImage.type = ImageAsset.Icon;
        
        LabelAccessoryCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        NativeAssetTitle *title = [[NativeAssetTitle alloc] initWithLength:(int)titleCell.lblSelectedContent.text required:YES];
        
        NSMutableArray<NativeAsset *> *addedAssets = [NSMutableArray arrayWithArray:self.nativeRequest.assets];
        [addedAssets addObject:mainImage];
        [addedAssets addObject:iconImage];
        [addedAssets addObject:title];
        self.nativeRequest.assets = addedAssets;
    }
    ((AppDelegate*)[UIApplication sharedApplication].delegate).nativeRequest = self.nativeRequest;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)doneWithNumberPad:(UIBarButtonItem *)sender
{
    [self.tableView endEditing:YES];
}

-(void) sendSelectedAssets:(NSString *)assets{
    self.dataAssets = assets;
}

-(void) sendSelectedEvents:(NSString *)events{
    self.eventType = events;
}

#pragma mark -  Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"return here");
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
    return 8;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row > 2)
        return 65.0f;
    else
        return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == 1){
        static NSString *imageCell = @"ImageCell";
        
        ImageCell *cell = (ImageCell *)[tableView dequeueReusableCellWithIdentifier:imageCell];
        
        if(cell != nil){
            if(indexPath.row == 0){
                cell.lblHeader.text = @"Main Image";
            } else {
                cell.lblHeader.text = @"Icon Image";
            }
        }
        cell.txtMinWidth.keyboardType = UIKeyboardTypeNumberPad;
        cell.txtMinHeight.keyboardType = UIKeyboardTypeNumberPad;
        return cell;
    } else if(indexPath.row == 2){
        static NSString *labelAccessoryCell = @"LabelAccessoryCell";
        
        LabelAccessoryCell *cell = (LabelAccessoryCell *)[tableView dequeueReusableCellWithIdentifier:labelAccessoryCell];
        
        if(cell != nil){
            cell.lblTitle.text = @"Title";
            if(self.titleLength != nil && self.titleLength.length > 0)
                cell.lblSelectedContent.text = self.titleLength;
            else
                cell.lblSelectedContent.placeholder = @"0";
            cell.lblSelectedContent.keyboardType = UIKeyboardTypeNumberPad;
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
    }else if(indexPath.row == 3){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = @"Data Assets";
            if (self.dataAssets == nil || self.dataAssets.length == 0) {
                cell.lblId.text = @" ";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else{
                cell.lblId.text = self.dataAssets;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }else if(indexPath.row == 4){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = @"Context";
            if(self.nativeRequest.context == nil){
                cell.lblId.text = @" ";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else{
                ContextType *contextValue = self.nativeRequest.context;
                if(contextValue == ContextType.Social){
                    cell.lblId.text = @"Social";
                } else if (contextValue == ContextType.Content){
                    cell.lblId.text = @"Content";
                }else if (contextValue == ContextType.Product){
                     cell.lblId.text = @"Product";
                }
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    } else if(indexPath.row == 5){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = @"Context Subtype";
            if (self.nativeRequest.contextSubType == nil) {
                
                cell.lblId.text = @" ";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else{
                
                ContextSubType *rowValue = self.nativeRequest.contextSubType;
                
                NSString *valueString = @"";
                if(rowValue == ContextSubType.General){
                    valueString = @"General";
                } else if (rowValue == ContextSubType.Article){
                    valueString = @"Article";
                }else if (rowValue == ContextSubType.Video){
                    valueString = @"Video";
                }else if (rowValue == ContextSubType.Audio){
                    valueString = @"Audio";
                }else if (rowValue == ContextSubType.Image){
                    valueString = @"Image";
                }else if (rowValue == ContextSubType.UserGenerated){
                    valueString = @"UserGenerated";
                }else if (rowValue == ContextSubType.Social){
                    valueString = @"Social";
                }else if (rowValue == ContextSubType.email){
                    valueString = @"email";
                }else if (rowValue == ContextSubType.chatIM){
                    valueString = @"chatIM";
                }else if (rowValue == ContextSubType.SellingProduct){
                    valueString = @"SellingProduct";
                }else if (rowValue == ContextSubType.AppStore){
                    valueString = @"AppStore";
                }else if (rowValue == ContextSubType.ReviewSite){
                    valueString = @"ReviewSite";
                }
                cell.lblId.text = valueString;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }else if(indexPath.row == 6){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = @"Placement type";
            if (self.nativeRequest.placementType == nil) {
                
                cell.lblId.text = @" ";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else{
                PlacementType *rowValue = self.nativeRequest.placementType;
                               
               NSString *valueString = @"";
               if(rowValue == PlacementType.AtomicContent){
                   valueString = @"AtomicContent";
               } else if (rowValue == PlacementType.FeedContent){
                   valueString = @"FeedContent";
               }else if (rowValue == PlacementType.RecommendationWidget){
                   valueString = @"RecommendationWidget";
               }else if (rowValue == PlacementType.OutsideContent){
                   valueString = @"OutsideContent";
               }
                
                cell.lblId.text = valueString;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }else if(indexPath.row == 7){
        static NSString *idCell = @"IdCell";
        
        IdCell *cell = (IdCell *)[tableView dequeueReusableCellWithIdentifier:idCell];
        
        if(cell != nil){
            cell.lblIDText.text = @"Event type";
            if (self.eventType == nil || [self.eventType isEqualToString:@""]) {
                cell.lblId.text = @" ";
                [cell.lblId setTextColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
            } else{
                cell.lblId.text = self.eventType;
                [cell.lblId setTextColor:[UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0]];
                [cell.lblIDText setTextColor:[UIColor colorWithRed:0.56 green:0.56 blue:0.58 alpha:1.0]];
            }
        }
        return cell;
    }
    

    return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row > 2 && indexPath.row < 8){
        
        LabelAccessoryCell *titleCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        self.titleLength = titleCell.lblSelectedContent.text;
        
        AssetsViewController *controller = [[AssetsViewController alloc] init];
        if(indexPath.section == 0 && indexPath.row == 3){
            controller.delegate = self;
            [controller setTitle:@"Native Assets - Data"];
            controller.assetType = @"Data Assets";
        } else if(indexPath.section == 0 && indexPath.row == 4){
            [controller setTitle:@"Native Assets - Context"];
            controller.assetType = @"Context";
        } else if(indexPath.section == 0 && indexPath.row == 5){
            [controller setTitle:@"Native Assets - Context SubType"];
            controller.assetType = @"ContextSubType";
        } else if(indexPath.section == 0 && indexPath.row == 6){
            [controller setTitle:@"Native Assets - Placement Type"];
            controller.assetType = @"PlacementType";
        } else if(indexPath.section == 0 && indexPath.row == 7){
            controller.delegate = self;
            [controller setTitle:@"Native Assets - Events"];
            controller.assetType = @"Events";
        }

        controller.nativeRequest = self.nativeRequest;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}


    


@end
