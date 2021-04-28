//
//  OXMOpenMeasurementSessionObjcTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PBMOpenMeasurementSession.h"

@interface PBMOpenMeasurementSessionObjcTest : XCTestCase

@end

@implementation PBMOpenMeasurementSessionObjcTest

-(void)testInitiWithInvalidParams {
    OMIDPrebidorgAdSessionContext *context = nil;
    OMIDPrebidorgAdSessionConfiguration *configuration = nil;
    
    PBMOpenMeasurementSession *session = [[PBMOpenMeasurementSession alloc] initWithContext:context configuration:configuration];
    XCTAssertNil(session);
}

@end
