//
//  OXMOpenMeasurementSessionObjcTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OXMOpenMeasurementSession.h"

@interface OXMOpenMeasurementSessionObjcTest : XCTestCase

@end

@implementation OXMOpenMeasurementSessionObjcTest

-(void)testInitiWithInvalidParams {
    OMIDOpenxAdSessionContext *context = nil;
    OMIDOpenxAdSessionConfiguration *configuration = nil;
    
    OXMOpenMeasurementSession *session = [[OXMOpenMeasurementSession alloc] initWithContext:context configuration:configuration];
    XCTAssertNil(session);
}

@end
