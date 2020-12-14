//
//  PrebidNativeAdView.h
//  Dr.Prebid
//
//  Created by Akash.Verma on 14/12/20.
//  Copyright © 2020 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrebidNativeAdView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *callToActionButton;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredLabel;

@end

NS_ASSUME_NONNULL_END
