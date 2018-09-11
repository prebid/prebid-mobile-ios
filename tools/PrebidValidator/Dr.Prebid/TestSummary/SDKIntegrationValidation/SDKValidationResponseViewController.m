//
//  SDKValidationResponseViewController.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 9/11/18.
//  Copyright © 2018 Prebid. All rights reserved.
//


#import "SDKValidationResponseViewController.h"
#import "ColorTool.h"

@interface SDKValidationResponseViewController ()
@property PBVPrebidSDKValidator *validator;
@end

@implementation SDKValidationResponseViewController

- (instancetype)initWithValidator:(PBVPrebidSDKValidator *)validator
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
    UIScrollView *container = [[UIScrollView alloc]initWithFrame:self.view.frame];
    container.scrollEnabled = YES;
    self.view = container;
    self.view.backgroundColor = [ColorTool prebidGrey];
}
@end


