//
//  RenderingBannerViewController.h
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderingBannerViewController : UIViewController

@property (nonatomic, strong) NSString *adServer;
@property (nonatomic, strong) NSString *adUnit;

@end

NS_ASSUME_NONNULL_END
