//
//  OXMMRAIDControllerObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

//#import "OXMMRAIDController.h"
#import "OXASDKConfiguration.h"
#import "OpenXSDKCoreTests-Swift.h"

@interface OXMMRAIDControllerObjCTest : XCTestCase
@end

@implementation OXMMRAIDControllerObjCTest

- (void) testCommandWithBadParams {
    OXMMRAIDController *controller = [OXMMRAIDController new];

    XCTAssertThrows([controller commandFromURL:nil]);
}

@end
