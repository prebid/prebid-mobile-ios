//
//  DemandHeaderCell.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/6/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "DemandHeaderCell.h"

@implementation DemandHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (IBAction)selectedHeaderCell:(id)sender {
    [self.delegate didSelectUserHeaderTableViewCell:YES UserHeader:self];
}
@end
