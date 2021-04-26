//
//  OXMMRAIDControllerObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PBMSDKConfiguration.h"
#import "PrebidMobileRenderingTests-Swift.h"

@interface PBMMRAIDControllerObjCTest : XCTestCase
@end

@implementation PBMMRAIDControllerObjCTest

- (void) testCommandWithBadParams {
    PBMMRAIDController *controller = [PBMMRAIDController new];

    XCTAssertThrows([controller commandFromURL:nil]);
}

@end
