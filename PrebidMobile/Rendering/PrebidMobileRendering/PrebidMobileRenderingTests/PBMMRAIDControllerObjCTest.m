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
    PBMMRAIDController *controller = [[PBMMRAIDController alloc] initWithCreative:nil
                                                      viewControllerForPresenting:nil
                                                                          webView:nil
                                                             creativeViewDelegate:nil
                                                                    downloadBlock:nil];

    XCTAssertThrows([controller commandFromURL:nil]);
}

@end
