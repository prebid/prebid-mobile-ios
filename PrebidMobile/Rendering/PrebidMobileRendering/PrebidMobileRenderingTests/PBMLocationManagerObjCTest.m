//
//  OXMLocationManagerObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrebidMobileRenderingTests-Swift.h"

@interface PBMLocationManagerObjCTest : XCTestCase

@end

@implementation PBMLocationManagerObjCTest

- (void)testValidLocationWithNSObject {
    PBMLocationManager *locationManager = [PBMLocationManager singleton];
    XCTAssertFalse([locationManager locationIsValid: (CLLocation*)[NSObject new]]);
}

@end
