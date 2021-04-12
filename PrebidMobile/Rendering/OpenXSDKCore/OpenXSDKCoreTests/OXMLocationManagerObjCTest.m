//
//  OXMLocationManagerObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OpenXSDKCoreTests-Swift.h"

@interface OXMLocationManagerObjCTest : XCTestCase

@end

@implementation OXMLocationManagerObjCTest

- (void)testValidLocationWithNSObject {
    OXMLocationManager *locationManager = [OXMLocationManager singleton];
    XCTAssertFalse([locationManager locationIsValid: (CLLocation*)[NSObject new]]);
}

@end
