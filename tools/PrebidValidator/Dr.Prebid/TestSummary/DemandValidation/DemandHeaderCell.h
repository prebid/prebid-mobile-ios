//
//  DemandHeaderCell.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/6/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DemandHeaderCellDelegate <NSObject>
-(void)didSelectUserHeaderTableViewCell:(BOOL) isSelected UserHeader:(id)headerCell;
@end

@interface DemandHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblLeftHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblRightHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnDetail;

@property (nonatomic,readwrite,weak) id<DemandHeaderCellDelegate> delegate;
- (IBAction)selectedHeaderCell:(id)sender;

@end


