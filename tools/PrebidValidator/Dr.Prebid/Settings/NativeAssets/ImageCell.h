//
//  ImageCell.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 8/19/20.
//  Copyright © 2020 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UITextField *txtMinWidth;
@property (weak, nonatomic) IBOutlet UITextField *txtMinHeight;

@end

NS_ASSUME_NONNULL_END
