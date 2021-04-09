//
//  OXMOpenMeasurementWrapperObjcTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OXMFunctions+Private.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMOpenMeasurementWrapper+oxmTestExtension.h"

@import OpenXApolloSDK;

@interface OXMOpenMeasurementWrapperObjcTest : XCTestCase

@end

@implementation OXMOpenMeasurementWrapperObjcTest

- (void)testInjectNilHTML {
    OXMOpenMeasurementWrapper *measurement = [OXMOpenMeasurementWrapper new];
    measurement.jsLib = @"test JS";
    
    NSString *html = nil;
    
    NSError *error;
    NSString *htmlWithMeasurementJS = [measurement injectJSLib:html error:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(htmlWithMeasurementJS);
}

@end
