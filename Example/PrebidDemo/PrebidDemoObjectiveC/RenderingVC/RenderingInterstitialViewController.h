//
//  RenderingBannerViewController.h
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegrationKind.h"

NS_ASSUME_NONNULL_BEGIN

@interface RenderingInterstitialViewController : UIViewController

@property (nonatomic) IntegrationKind integrationKind;

@end

NS_ASSUME_NONNULL_END
