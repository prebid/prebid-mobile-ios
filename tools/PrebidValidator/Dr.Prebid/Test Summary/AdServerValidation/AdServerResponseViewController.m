//
//  AdServerResponseViewController.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 8/24/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdServerResponseViewController.h"
#import "PBVSharedConstants.h"

@interface AdServerResponseViewController()
@property PBVLineItemsSetupValidator * validator;
@end

@implementation AdServerResponseViewController
- (instancetype)initWithValidator:(PBVLineItemsSetupValidator *)validator
{
    self = [super init];
    if (self) {
        self.validator = validator;
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"Creative Display";
    self.view.backgroundColor = [UIColor whiteColor];
   
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    
    if ([adFormatName isEqualToString:kBannerString]) {
        UIView *adView = (UIView *)[_validator getDisplayable];
        adView.frame = CGRectMake(100, 100,  300, 250);
        [self.view addSubview:adView];
//        UIView *adView = (UIView *)[self.validator getDisplayable];
//        adView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//        [self.view addSubview: adView];
    } else {
        // build it as a click to show
    }

}
@end
