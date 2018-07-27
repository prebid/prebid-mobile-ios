//
//  SegmentCell.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 7/10/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end
