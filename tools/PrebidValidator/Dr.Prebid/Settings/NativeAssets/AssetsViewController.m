//
//  AssetsViewController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 8/19/20.
//  Copyright © 2020 Prebid. All rights reserved.
//

#import "AssetsViewController.h"
@import PrebidMobile;

@interface AssetsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NativeAssetData *> *assetsDataArray;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *eventsArray;

@property (nonatomic, strong) NSString* assetsString;

@property (nonatomic, strong) NSString* eventsString;

@end

@implementation AssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.assetType isEqualToString:@"Data Assets"]){
        self.assetsDataArray = [[NSMutableArray alloc] init];
        self.assetsString = @"";
    }
    if([self.assetType isEqualToString:@"Events"]){
        self.eventsArray = [[NSMutableArray alloc] init];
        self.eventsString = @"";
    }
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.target = self;
    doneButton.action = @selector(doneAction:);
    doneButton.title = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.assetType isEqualToString:@"Data Assets"]){
        return DataAssetCtatext;
    } else if([self.assetType isEqualToString:@"Context"]){
        return ContextType.Product.value;
    } else if([self.assetType isEqualToString:@"ContextSubType"]){
        return 12;
    } else if([self.assetType isEqualToString:@"PlacementType"]){
        return 4;
    } else if([self.assetType isEqualToString:@"Events"]){
        return 4;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    NSInteger numValue = 0;
    NSString *valueString = @"";
    if([self.assetType isEqualToString:@"Data Assets"]) {
        numValue = (DataAsset)indexPath.row + 1;
        valueString = [self populateDataAssets:numValue];
    } else if([self.assetType isEqualToString:@"Context"]){
        numValue = indexPath.row + 1;
        valueString = [self populateContextType:numValue];
    } else if([self.assetType isEqualToString:@"ContextSubType"]){
        if(indexPath.row <= 5)
            numValue = indexPath.row + 10;
        else if (indexPath.row > 5 && indexPath.row <= 8){
            numValue = indexPath.row + 14;
        } else if (indexPath.row > 8 && indexPath.row <= 11){
            numValue = indexPath.row + 21;
        }
        valueString = [self populateContextSubType:numValue];
    } else if([self.assetType isEqualToString:@"PlacementType"]){
        numValue = indexPath.row + 1;
        valueString = [self populatePlacementType:numValue];
    } else if([self.assetType isEqualToString:@"Events"]){
        numValue = indexPath.row + 1;
        valueString = [self populateEvents:numValue];
    }
    cell.textLabel.text = valueString;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    return cell;
}

-(NSString *) populateDataAssets:(NSInteger) rowValue {
    NSString *valueString;
    switch (rowValue) {
        case DataAssetDescription2:
            valueString = @"Description2";
            break;
         case DataAssetLikes:
            valueString = @"Likes";
            break;
        case DataAssetPhone:
            valueString = @"Phone";
            break;
        case DataAssetPrice:
            valueString = @"Price";
            break;
        case DataAssetRating:
            valueString = @"Rating";
            break;
        case DataAssetAddress:
            valueString = @"Address";
            break;
        case DataAssetCtatext:
            valueString = @"CTAText";
            break;
        case DataAssetDownloads:
            valueString = @"Downloads";
            break;
        case DataAssetSaleprice:
            valueString = @"SalePrice";
            break;
        case DataAssetSponsored:
            valueString = @"Sponsored";
            break;
        case DataAssetDisplayurl:
            valueString = @"DisplayUrl";
            break;
        case DataAssetDescription:
            valueString = @"Description";
            break;
        default:
            break;
    }
    
    return valueString;
}

-(NSString *) populateContextType:(NSInteger) rowValue {
    NSString *valueString;
    if(rowValue == ContextType.Social.value){
        valueString = @"Social";
    } else if (rowValue == ContextType.Content.value){
        valueString = @"Content";
    }else if (rowValue == ContextType.Product.value){
        valueString = @"Product";
    }
    
    return valueString;
}

-(NSString *) populateContextSubType:(NSInteger) rowValue {
    NSString *valueString;
    if(rowValue == ContextSubType.General.value){
        valueString = @"General";
    } else if (rowValue == ContextSubType.Article.value){
        valueString = @"Article";
    }else if (rowValue == ContextSubType.Video.value){
        valueString = @"Video";
    }else if (rowValue == ContextSubType.Audio.value){
        valueString = @"Audio";
    }else if (rowValue == ContextSubType.Image.value){
        valueString = @"Image";
    }else if (rowValue == ContextSubType.UserGenerated.value){
        valueString = @"UserGenerated";
    }else if (rowValue == ContextSubType.Social.value){
        valueString = @"Social";
    }else if (rowValue == ContextSubType.email.value){
        valueString = @"email";
    }else if (rowValue == ContextSubType.chatIM.value){
        valueString = @"chatIM";
    }else if (rowValue == ContextSubType.SellingProduct.value){
        valueString = @"SellingProduct";
    }else if (rowValue == ContextSubType.AppStore.value){
        valueString = @"AppStore";
    }else if (rowValue == ContextSubType.ReviewSite.value){
        valueString = @"ReviewSite";
    }
    return valueString;
}

-(NSString *) populatePlacementType:(NSInteger) rowValue {
    NSString *valueString;
    if(rowValue == PlacementType.AtomicContent.value){
        valueString = @"AtomicContent";
    } else if (rowValue == PlacementType.FeedContent.value){
        valueString = @"FeedContent";
    }else if (rowValue == PlacementType.RecommendationWidget.value){
        valueString = @"RecommendationWidget";
    }else if (rowValue == PlacementType.OutsideContent.value){
        valueString = @"OutsideContent";
    }
    
    return valueString;
}

-(NSString *) populateEvents:(NSInteger) rowValue {
    NSString *valueString;
    if(rowValue == EventType.Impression.value){
        valueString = @"Impression";
    } else if (rowValue == EventType.ViewableImpression50.value){
        valueString = @"ViewableImpression50";
    }else if (rowValue == EventType.ViewableImpression100.value){
        valueString = @"ViewableImpression100";
    }else if (rowValue == EventType.ViewableVideoImpression50.value){
        valueString = @"ViewableVideoImpression50";
    }
    
    return valueString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCellAccessoryType type =  [tableView cellForRowAtIndexPath:indexPath].accessoryType;
    NSInteger numValue = indexPath.row+1;
    if([self.assetType isEqualToString:@"Data Assets"]){
    
       NativeAssetData *assetData = [[NativeAssetData alloc] initWithType:numValue required:YES];
       
    
       if(type == UITableViewCellAccessoryNone){
           [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
           [self.assetsDataArray addObject:assetData];
           NSLog(@"cell text: %@", cell.textLabel.text);
           if (numValue == DataAssetLikes) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Likes"];
           }else if (numValue == DataAssetCtatext) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"ctaText"];
           }else if (numValue == DataAssetPhone) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Phone"];
           }else if (numValue == DataAssetPrice) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Price"];
           }else if (numValue == DataAssetRating) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Rating"];
           }else if (numValue == DataAssetAddress) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Address"];
           }else if (numValue == DataAssetDownloads) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Downloads"];
           }else if (numValue == DataAssetSaleprice) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"SalePrice"];
           }else if (numValue == DataAssetSponsored) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Sponsored"];
           }else if (numValue == DataAssetDisplayurl) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"DisplayUrl"];
           }else if (numValue == DataAssetDescription) {
               self.assetsString = [NSString stringWithFormat:@"%@ %@",self.assetsString,@"Description"];
           }
       } else if(type == UITableViewCellAccessoryCheckmark){
           if (numValue == DataAssetLikes) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Likes" withString:@""];
           }else if (numValue == DataAssetCtatext) {
               self.assetsString =[self.assetsString stringByReplacingOccurrencesOfString:@"ctaText" withString:@""];
           }else if (numValue == DataAssetPhone) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Phone" withString:@""];
           }else if (numValue == DataAssetPrice) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Price" withString:@""];
           }else if (numValue == DataAssetRating) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Rating" withString:@""];
           }else if (numValue == DataAssetAddress) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Address" withString:@""];
           }else if (numValue == DataAssetDownloads) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Downloads" withString:@""];
           }else if (numValue == DataAssetSaleprice) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"SalePrice" withString:@""];
           }else if (numValue == DataAssetSponsored) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Sponsored" withString:@""];
           }else if (numValue == DataAssetDisplayurl) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"DisplayUrl" withString:@""];
           }else if (numValue == DataAssetDescription) {
               self.assetsString = [self.assetsString stringByReplacingOccurrencesOfString:@"Description" withString:@""];
           }
           
           
           [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
           [self.assetsDataArray removeObject:assetData];
       }
    } else if([self.assetType isEqualToString:@"Context"]){
        for (UITableViewCell *cell in [tableView visibleCells]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        if(numValue == ContextType.Social.value){
            self.nativeRequest.context = ContextType.Social;
        } else if (numValue == ContextType.Content.value){
            self.nativeRequest.context = ContextType.Content;
        }else if (numValue == ContextType.Product.value){
            self.nativeRequest.context = ContextType.Product;
        }
    } else if([self.assetType isEqualToString:@"ContextSubType"]){
        for (UITableViewCell *cell in [tableView visibleCells]){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        if(indexPath.row <= 5)
            numValue = indexPath.row + 10;
        else if (indexPath.row > 5 && indexPath.row <= 8){
            numValue = indexPath.row + 14;
        } else if (indexPath.row > 8 && indexPath.row <= 11){
            numValue = indexPath.row + 21;
        }
        if(numValue == ContextSubType.General.value){
            self.nativeRequest.contextSubType = ContextSubType.General;
        } else if (numValue == ContextSubType.Article.value){
            self.nativeRequest.contextSubType = ContextSubType.Article;
        }else if (numValue == ContextSubType.Video.value){
            self.nativeRequest.contextSubType = ContextSubType.Video;
        }else if (numValue == ContextSubType.Audio.value){
            self.nativeRequest.contextSubType = ContextSubType.Audio;
        }else if (numValue == ContextSubType.Image.value){
            self.nativeRequest.contextSubType = ContextSubType.Image;
        }else if (numValue == ContextSubType.UserGenerated.value){
            self.nativeRequest.contextSubType = ContextSubType.UserGenerated;
        }else if (numValue == ContextSubType.Social.value){
            self.nativeRequest.contextSubType = ContextSubType.Social;
        }else if (numValue == ContextSubType.email.value){
            self.nativeRequest.contextSubType = ContextSubType.email;
        }else if (numValue == ContextSubType.chatIM.value){
            self.nativeRequest.contextSubType = ContextSubType.chatIM;
        }else if (numValue == ContextSubType.SellingProduct.value){
            self.nativeRequest.contextSubType = ContextSubType.SellingProduct;
        }else if (numValue == ContextSubType.AppStore.value){
            self.nativeRequest.contextSubType = ContextSubType.AppStore;
        }else if (numValue == ContextSubType.ReviewSite.value){
            self.nativeRequest.contextSubType = ContextSubType.ReviewSite;
        }
    }else if([self.assetType isEqualToString:@"PlacementType"]){
        for (UITableViewCell *cell in [tableView visibleCells]){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
        if(numValue == PlacementType.AtomicContent.value){
            self.nativeRequest.placementType = PlacementType.AtomicContent;
        } else if (numValue == PlacementType.FeedContent.value){
            self.nativeRequest.placementType = PlacementType.FeedContent;
        }else if (numValue == PlacementType.RecommendationWidget.value){
            self.nativeRequest.placementType = PlacementType.RecommendationWidget;
        }else if (numValue == PlacementType.OutsideContent.value){
            self.nativeRequest.placementType = PlacementType.OutsideContent;
        }
    } else if([self.assetType isEqualToString:@"Events"]){
        if(type == UITableViewCellAccessoryNone){
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [self.eventsArray addObject:[NSNumber numberWithInteger:numValue]];
            
        } else if(type == UITableViewCellAccessoryCheckmark){
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
            [self.eventsArray removeObject:[NSNumber numberWithInteger:numValue]];
        }
    }
}

-(void) doneAction :(id) sender {
    if([self.assetType isEqualToString:@"Data Assets"]) {
        self.nativeRequest.assets = self.assetsDataArray;
        self.assetsString = [self.assetsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray* dataAssets = [self.assetsString componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* newString = [dataAssets componentsJoinedByString:@","];
        [self.delegate sendSelectedAssets:newString];
    } else if([self.assetType isEqualToString:@"Events"]){
        NSMutableArray <NativeEventTracker *> *nativeEventTrackers = [[NSMutableArray alloc] init];
        NSString *eventString = @"";
        for (NSNumber *number in self.eventsArray) {
            NSInteger eventNumber = number.integerValue;
            NativeEventTracker *eventTracker = nil;
            if(eventNumber == EventType.Impression.value){
                eventString = [NSString stringWithFormat:@"%@ %@",eventString, @"Impression"];
                eventTracker = [[NativeEventTracker alloc] initWithEvent:EventType.Impression methods:[NSArray arrayWithObjects:EventTracking.js,EventTracking.Image,nil]];
                
            } else if(eventNumber == EventType.ViewableImpression50.value){
                eventString = [NSString stringWithFormat:@"%@ %@",eventString, @"ViewableImpression50"];
                eventTracker = [[NativeEventTracker alloc] initWithEvent:EventType.ViewableImpression50 methods:[NSArray arrayWithObjects:EventTracking.js,EventTracking.Image,nil]];
            } else if(eventNumber == EventType.ViewableImpression100.value){
                eventString = [NSString stringWithFormat:@"%@ %@",eventString, @"ViewableImpression100"];
                eventTracker = [[NativeEventTracker alloc] initWithEvent:EventType.ViewableImpression100 methods:[NSArray arrayWithObjects:EventTracking.js,EventTracking.Image,nil]];
            } else if(eventNumber == EventType.ViewableVideoImpression50.value){
                eventString = [NSString stringWithFormat:@"%@ %@",eventString, @"ViewableVideoImpression50"];
                eventTracker = [[NativeEventTracker alloc] initWithEvent:EventType.ViewableVideoImpression50 methods:[NSArray arrayWithObjects:EventTracking.js,EventTracking.Image,nil]];
            }
            [nativeEventTrackers addObject:eventTracker];
            
        }
        
        self.nativeRequest.eventtrackers = nativeEventTrackers;
        [self.delegate sendSelectedEvents:eventString];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



@end
