//
//  PBFacebookAdLoader.m
//  PrebidMobile
//
//  Created by Nicole Hedley on 8/24/17.
//  Copyright © 2017 Nicole Hedley. All rights reserved.
//

#import "PBFacebookAdLoader.h"

@implementation PBFacebookAdLoader

+ (void)load {
    NSLog(@"LKSDJFKLSDFNKLJSDFLKJKLJDFSLJK JLK got in here");
    Class fbAdViewClass = NSClassFromString(@"FBAdView");
    NSAssert(fbAdViewClass != nil, @"FBAdView class needs to exist");
    SEL initMethodSel = NSSelectorFromString(@"initWithPlacementID:adSize:rootViewController:");
    NSAssert([fbAdViewClass instancesRespondToSelector:initMethodSel], @"Your demand source isn't implemented properly");
}


+ (void)initialize {
    NSLog(@"983749823749827348927348927389479823478923478923");
}

@end
