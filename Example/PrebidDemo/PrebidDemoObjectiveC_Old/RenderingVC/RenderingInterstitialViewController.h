//
//  RenderingBannerViewController.h
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegrationKind.h"
#import "VideoOrientation.h"

NS_ASSUME_NONNULL_BEGIN

@interface RenderingInterstitialViewController : UIViewController

@property (nonatomic) IntegrationKind integrationKind;
@property (nonatomic) IntegrationAdFormat integrationAdFormat;
@property (nonatomic) VideoOrientation videoOrienation;

@end

NS_ASSUME_NONNULL_END
