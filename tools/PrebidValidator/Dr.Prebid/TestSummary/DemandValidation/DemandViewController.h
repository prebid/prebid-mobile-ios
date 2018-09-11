//
//  DemandViewController.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/6/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemandViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSDictionary *resultsDictionary;
@end
