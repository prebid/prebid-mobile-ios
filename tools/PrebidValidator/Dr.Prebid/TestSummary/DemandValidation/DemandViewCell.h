//
//  DemandViewCell.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/6/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemandViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblRequests;
@property (weak, nonatomic) IBOutlet UILabel *lblValidBidRate;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgCPM;
@property (weak, nonatomic) IBOutlet UILabel *lblNoBidRate;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeoutRate;
@property (weak, nonatomic) IBOutlet UILabel *lblErrorRate;

@end
